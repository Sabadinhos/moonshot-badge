"""Render real gameplay footage (MP4) from main.lua's own draw calls for the launch film.

Simulator renders, not captures from the physical badge.
Usage: python make_footage.py <out_dir>
"""
import subprocess
import sys
from pathlib import Path

import sim_render

FPS = 30
STEP = 1000 / FPS
SCALE = 4  # 320x218 -> 1280x872, nearest neighbour keeps the pixel art crisp


class Shot:
    def __init__(self, seed, nearby=None):
        self.L, self.G, self.keys, self.scene = sim_render.load(seed, nearby=nearby)
        self.S = self.G._S
        self.frames = []
        self.marks = {}

    def tick(self, n=1, rec=True):
        for _ in range(n):
            self.G.on_tick(STEP)
            if rec:
                self.frames.append(sim_render.frame(self.scene, upscale=1))

    def hold(self, n):
        for _ in range(n):
            self.frames.append(sim_render.frame(self.scene, upscale=1))

    def mark(self, name):
        self.marks[name] = round(len(self.frames) / FPS, 3)

    def key(self, k):
        self.G.on_key(k, False)

    def kick(self, release_dy=0, wind=None, rec=True):
        S, keys = self.S, self.keys
        while S.mode == 'intro':
            self.tick(rec=rec)
        keys['select'] = False
        while S.mode == 'ready' and not S.armed:
            self.tick(rec=rec)
        self.tick(6, rec=rec)
        keys['select'] = True
        self.key('select')
        self.mark('press')
        while S.mode == 'drop':
            self.tick(rec=rec)
            # Release a frame ahead: the hit is judged on the next tick, ~1.1 px lower.
            if S.token.y + 4 - 47 >= release_dy - 1.2 and keys['select']:
                keys['select'] = False
                self.mark('hit')
        keys['select'] = False
        while S.mode in ('flight', 'miss', 'result') and len(self.frames) < 4000:
            before = S.swing
            self.tick(rec=rec)
            if S.mode == 'result' and 'land' not in self.marks:
                self.mark('land')
            if S.swing != before or S.mode in ('intro', 'end'):
                break
        return self.S.shots[self.S.swing] if self.S.shots else None

    def save(self, path):
        w, h = self.frames[0].size
        proc = subprocess.Popen([
            'ffmpeg', '-y', '-loglevel', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
            '-s', f'{w}x{h}', '-r', str(FPS), '-i', '-',
            '-vf', f'scale={w * SCALE}:{h * SCALE}:flags=neighbor',
            '-c:v', 'libx264', '-pix_fmt', 'yuv420p', '-crf', '14', '-preset', 'slow',
            '-movflags', '+faststart', str(path)], stdin=subprocess.PIPE)
        for f in self.frames:
            proc.stdin.write(f.convert('RGB').tobytes())
        proc.stdin.close()
        assert proc.wait() == 0, f'ffmpeg failed for {path}'
        print(f'{path.name}: {len(self.frames)} frames ({len(self.frames) / FPS:.2f}s) marks={self.marks}')


def kick_clip(out, name, map_index, seed, wind, skin_steps=0):
    s = Shot(seed)
    for _ in range(map_index - 1):
        s.key('right')
    for _ in range(skin_steps):
        s.key('down')
    s.key('select')
    s.frames.clear()
    s.kick(release_dy=0, wind=wind)
    s.tick(10)
    s.save(out / name)
    return s.S.shots[1]


def main(out):
    out = Path(out)
    out.mkdir(parents=True, exist_ok=True)
    dists = {}
    # One perfect kick on each London map, tailwind so the coin reaches the moon.
    # Seeds whose own random wind is a +6 tailwind, so the HUD stays truthful.
    dists['westminster'] = kick_clip(out, 'kick_westminster.mp4', 1, 15, None)
    dists['towerbridge'] = kick_clip(out, 'kick_towerbridge.mp4', 2, 31, None, skin_steps=2)
    dists['coventgarden'] = kick_clip(out, 'kick_coventgarden.mp4', 3, 37, None, skin_steps=3)
    dists['olympia'] = kick_clip(out, 'kick_olympia.mp4', 4, 49, None, skin_steps=1)

    # A mistimed early release, the honest fail beat.
    s = Shot(31)
    s.key('select')
    s.frames.clear()
    s.kick(release_dy=-24)
    s.tick(8)
    s.save(out / 'fail_early.mp4')

    # Menu: pick a map and a character.
    s = Shot(5)
    s.tick(12)
    for k in ('right', 'right', 'down', 'right', 'down', 'down', 'right'):
        s.key(k)
        s.tick(11)
    s.save(out / 'menu.mp4')

    # A full run off camera, recording only the result screen and the nearby ranks.
    nearby = [('BLDR01', '@builder'), ('VALI02', '@validator'), ('DEGN03', '@degen')]
    s = Shot(7, nearby=nearby)
    s.key('select')
    for _ in range(3):
        s.kick(release_dy=0, rec=False)
    while s.S.mode != 'end':
        s.tick(rec=False)
    s.mark('end')
    s.tick(75)
    for badge, score in (('BLDR01', 905), ('VALI02', 1188), ('DEGN03', 640)):
        s.G.on_mesh(badge, s.L.table(kind='stm-score', value=score))
    s.key('up')
    s.mark('ranks')
    s.tick(60)
    s.save(out / 'result_ranks.mp4')
    print('distances', dists, 'run total', int(s.S.total))


if __name__ == '__main__':
    main(sys.argv[1] if len(sys.argv) > 1 else 'footage')

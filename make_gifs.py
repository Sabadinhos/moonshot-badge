"""Render gameplay GIFs from main.lua's own draw calls (simulator, not a badge capture)."""
import sys
from pathlib import Path

from PIL import Image

import sim_render

OUT = Path(__file__).resolve().parent / 'shots' / 'gifs'
OUT.mkdir(parents=True, exist_ok=True)
STEP_MS = 30


class Run:
    def __init__(self, seed=7):
        self.L, self.G, self.keys, self.scene = sim_render.load(seed)
        self.frames = []
        self.ticks = 0

    def mode(self):
        return self.G._S.mode

    def tick(self, n=1, capture=True, every=2):
        # Count ticks across calls: the game loops call tick(1) repeatedly.
        for _ in range(n):
            self.G.on_tick(STEP_MS)
            self.ticks += 1
            if capture and self.ticks % every == 0:
                self.frames.append(sim_render.frame(self.scene))

    def key(self, k):
        self.G.on_key(k, False)

    def press(self):
        self.keys['select'] = True
        self.key('select')

    def release(self):
        self.keys['select'] = False

    def arm(self):
        """Walk through the intro and the input-safe ready beat."""
        while self.mode() == 'intro':
            self.tick()
        self.release()
        while self.mode() == 'ready' and not self.G._S.armed:
            self.tick()

    def kick(self, release_at_y=43, every=2):
        self.arm()
        self.press()
        assert self.mode() == 'drop', self.mode()
        while self.mode() == 'drop':
            self.tick(every=every)
            if self.G._S.token.y >= release_at_y:
                self.release()
        self.release()
        n = 0
        while self.mode() in ('flight', 'miss', 'result') and n < 400:
            self.tick(every=every)
            n += 1
        return n

    def save(self, name, ms=60, keep=None, scale=1):
        assert self.frames, 'no frames captured'
        frames = self.frames[:keep] if keep else self.frames
        if scale != 1:
            w, h = frames[0].size
            frames = [f.resize((int(w * scale), int(h * scale)), Image.Resampling.NEAREST)
                      for f in frames]
        # One shared adaptive palette keeps the file small and stops colour flicker.
        base = frames[0].quantize(colors=64, method=Image.Quantize.MAXCOVERAGE)
        frames = [f.quantize(palette=base, dither=Image.Dither.NONE) for f in frames]
        path = OUT / name
        frames[0].save(path, save_all=True, append_images=frames[1:], duration=ms,
                       loop=0, optimize=True, disposal=2)
        print(f'{path.name}: {len(frames)} frames, {path.stat().st_size // 1024} KB')
        return path


def gif_menu():
    """Map and character selection on the title screen."""
    r = Run()
    assert r.mode() == 'title'
    r.tick(10)
    for _ in range(3):
        r.key('right')
        r.tick(10)
    for _ in range(3):
        r.key('down')
        r.tick(10)
    r.key('right')
    r.tick(12)
    return r.save('01_menu.gif', ms=70)


def gif_kick():
    """Intro, charge, hit and the coin flying across the map."""
    r = Run(seed=11)
    r.key('select')
    r.kick(release_at_y=43, every=3)
    return r.save('02_kick.gif', ms=80)


def gif_run():
    """A full three-kick run ending on the result screen."""
    r = Run(seed=5)
    r.key('select')
    for y in (43, 40, 44):
        r.kick(release_at_y=y, every=7)
    assert r.mode() == 'end', r.mode()
    r.tick(60, every=7)
    return r.save('03_full_run.gif', ms=150, scale=0.75)


def gif_pause():
    """CANCEL pauses play instead of dropping the player out of the app."""
    r = Run(seed=3)
    r.key('select')
    r.arm()
    r.press()
    r.tick(8)
    r.key('back')
    assert r.mode() == 'pause', r.mode()
    # The play message must not sit on top of the modal panel.
    visible = [lb.text_value for lb in r.scene['labels'] if lb.visible and lb.text_value]
    assert 'KEEP HOLDING' not in visible, visible
    assert 'PAUSED' in visible, visible
    r.tick(14)
    r.key('select')
    r.tick(12)
    return r.save('04_pause.gif', ms=70)


if __name__ == '__main__':
    wanted = sys.argv[1:] or ['menu', 'kick', 'run', 'pause']
    made = []
    for name in wanted:
        made.append(globals()['gif_' + name]())
    for p in made:
        with Image.open(p) as im:
            assert im.n_frames > 5, f'{p.name} has too few frames'
            assert im.size[0] >= 480, im.size
        assert p.stat().st_size < 3_500_000, f'{p.name} is too heavy to share'
    print('OK:', len(made), 'GIFs in', OUT)

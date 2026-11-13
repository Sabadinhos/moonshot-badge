"""Original SOL TO THE MOON sprite source. Run to regenerate both preview sheets.

Each 16x18 character shares a soft Solana-inspired palette and a 12px-ish
head/body rhythm. No perimeter outline: silhouettes are defined by color masses.
The script also prints the Lua SKINS table for main.lua when passed --lua.
"""
from pathlib import Path
from PIL import Image, ImageDraw
import sys

W, H = 16, 18
# Skin, cloth and highlights are close enough to belong to one cast.
PALETTE = {
    '.': (0, 0, 0, 0),
    'i': (45, 40, 61, 255),   # ink: eyes, glasses only
    'h': (67, 52, 79, 255),   # hair / deep shadow
    'd': (105, 82, 112, 255), # hair highlight
    'f': (244, 199, 164, 255),# skin / peach
    's': (214, 152, 127, 255),# skin shadow
    'm': (188, 125, 94, 255), # medium warm skin
    'M': (145, 87, 70, 255),  # medium skin shadow
    'n': (127, 82, 70, 255),  # deeper warm skin
    'N': (92, 57, 56, 255),   # deeper skin shadow
    'c': (255, 234, 207, 255),# warm cream / muzzle
    'a': (101, 193, 175, 255),# seafoam jacket
    'A': (55, 136, 145, 255), # deep teal jacket
    'v': (128, 112, 177, 255),# lavender
    'V': (87, 76, 132, 255),  # violet shade
    'o': (233, 160, 111, 255),# fox / warm orange
    'r': (220, 89, 99, 255),  # red accent: glasses only
    'g': (176, 181, 188, 255),# silver hair
    'w': (250, 248, 232, 255),# reflection
}


def sprite(name):
    grid = [['.'] * W for _ in range(H)]
    def box(x1, y1, x2, y2, col):
        for y in range(y1, y2 + 1):
            for x in range(x1, x2 + 1):
                if 0 <= x < W and 0 <= y < H:
                    grid[y][x] = col
    def dot(x, y, col): box(x, y, x, y, col)
    def eyes(y=7):
        dot(5, y, 'i'); dot(10, y, 'i')
        dot(5, y-1, 'w'); dot(10, y-1, 'w')

    if name == 'DUCK':
        # Soft round duck silhouette, small crest and a projecting beak.
        box(6, 0, 8, 1, 'c'); box(4, 2, 11, 10, 'c')
        box(3, 4, 12, 9, 'c'); box(5, 3, 10, 3, 'w')
        box(4, 7, 5, 7, 'i'); box(9, 7, 10, 7, 'i')
        box(5, 9, 10, 9, 'o'); box(6, 10, 9, 10, 'o')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 12, 9, 13, 'v'); box(5, 17, 6, 17, 'o'); box(9, 17, 10, 17, 'o')
    elif name == 'CUTE ANIMAL':
        # Keep the well-liked fox silhouette: tall ears and cheek tufts.
        box(2, 0, 4, 4, 'o'); box(11, 0, 13, 4, 'o')
        box(3, 1, 3, 3, 's'); box(12, 1, 12, 3, 's')
        box(4, 3, 11, 10, 'o'); box(2, 5, 13, 9, 'o')
        box(3, 8, 5, 10, 'c'); box(10, 8, 12, 10, 'c')
        eyes(7); box(7, 9, 8, 9, 'h'); box(6, 10, 9, 10, 'c')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 12, 9, 13, 'c'); box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
        box(12, 15, 14, 15, 'o'); box(14, 13, 15, 14, 'c')
    elif name == 'BEANIE DEGEN':
        # Oversized asymmetrical beanie and a lowered brim, same jacket.
        box(3, 1, 11, 5, 'v'); box(2, 3, 12, 5, 'v'); box(4, 0, 8, 1, 'V')
        box(3, 5, 12, 6, 'V'); box(4, 7, 11, 10, 'f')
        box(3, 8, 3, 9, 's'); box(12, 8, 12, 9, 's')
        eyes(8); dot(7, 10, 'i'); dot(8, 11, 's')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 13, 9, 14, 'V'); box(7, 12, 8, 12, 'v')
        box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'SENIOR DEV':
        # Tall silver quiff, thin frames, short beard, teal coat.
        box(3, 3, 12, 10, 'f'); box(3, 1, 10, 4, 'g')
        box(4, 0, 7, 1, 'w'); box(8, 2, 12, 3, 'g'); box(3, 6, 3, 8, 'g')
        box(4, 7, 6, 7, 'V'); box(9, 7, 11, 7, 'V'); box(7, 7, 8, 7, 'V')
        eyes(8); box(5, 10, 10, 10, 'g'); box(6, 11, 9, 11, 'g')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(5, 12, 6, 14, 'c'); box(9, 12, 10, 14, 'c')
        box(7, 13, 8, 15, 'V'); box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'PONYTAIL DEV':
        # Off-center ponytail, side fringe, plain jacket. No makeup cues.
        box(4, 1, 11, 5, 'h'); box(11, 3, 14, 5, 'h')
        box(13, 5, 15, 9, 'd'); box(13, 9, 14, 11, 'h')
        box(4, 4, 11, 10, 'f'); box(3, 6, 3, 9, 'h')
        box(4, 4, 8, 5, 'd'); box(4, 6, 5, 6, 'h')
        eyes(8); dot(7, 10, 's'); dot(8, 10, 's')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 12, 9, 13, 'v'); box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'BOB BUILDER':
        # Rounded bob, one longer side, a tiny lavender tool tucked in jacket.
        box(3, 2, 12, 10, 'd'); box(4, 1, 10, 3, 'h')
        box(4, 4, 11, 10, 'f'); box(3, 6, 4, 11, 'd')
        box(11, 6, 12, 9, 'h'); box(4, 4, 7, 4, 'h')
        eyes(8); box(7, 10, 8, 10, 's')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(10, 12, 10, 14, 'v'); dot(10, 11, 'w')
        box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'VALIDATOR':
        # Medium skin, tied-back braids and one discreet comms earpiece.
        box(4, 2, 11, 10, 'h'); box(11, 3, 13, 6, 'h')
        box(12, 7, 13, 12, 'd'); box(3, 5, 3, 11, 'd')
        box(4, 4, 11, 10, 'm'); box(4, 3, 9, 4, 'h')
        box(5, 7, 5, 8, 'i'); box(10, 7, 10, 8, 'i')
        dot(4, 8, 'v'); dot(4, 9, 'A'); box(7, 10, 8, 10, 'M')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 12, 9, 13, 'v'); box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'ONCHAIN ARTIST':
        # Deep skin, high asymmetric coils, lilac hair clip, paint on sleeve.
        box(3, 2, 12, 6, 'h'); box(4, 0, 8, 3, 'h')
        box(10, 1, 13, 4, 'd'); box(2, 4, 4, 8, 'h')
        box(4, 5, 11, 10, 'n'); box(3, 8, 3, 9, 'N')
        box(10, 3, 12, 3, 'v'); dot(11, 2, 'w')
        box(5, 7, 5, 8, 'i'); box(10, 7, 10, 8, 'i')
        dot(6, 10, 'N'); dot(9, 10, 'N')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(3, 13, 4, 13, 'v'); dot(3, 14, 'c')
        box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'DAO SCOUT':
        # Warm medium skin, cropped curls, seafoam visor and small badge.
        box(3, 2, 12, 6, 'h'); box(4, 1, 7, 3, 'd')
        box(9, 0, 11, 2, 'h'); box(3, 5, 12, 10, 'm')
        box(4, 4, 12, 5, 'A'); box(5, 4, 10, 4, 'a')
        box(5, 7, 5, 8, 'i'); box(10, 7, 10, 8, 'i')
        box(7, 10, 8, 10, 'M')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(9, 13, 10, 14, 'v'); dot(9, 13, 'w')
        box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    elif name == 'SABADINHOS':
        # User reference: dark curls, red sunglasses, smile; same cast uniform.
        box(3, 1, 12, 5, 'h'); box(2, 3, 13, 9, 'h')
        for x,y in ((4,1),(7,0),(10,1),(12,3),(3,5),(5,4),(9,3),(11,6)):
            box(x, y, x+1, y+1, 'd')
        box(4, 5, 11, 10, 'f'); box(3, 7, 3, 9, 's')
        box(4, 7, 7, 9, 'r'); box(9, 7, 12, 9, 'r'); box(7, 8, 9, 8, 'r')
        box(5, 8, 6, 9, 'i'); box(10, 8, 11, 9, 'i')
        dot(5, 8, 'w'); dot(10, 8, 'w'); box(6, 10, 10, 10, 's')
        box(7, 11, 9, 11, 'w')
        box(4, 12, 11, 16, 'a'); box(3, 13, 4, 15, 'A'); box(11, 13, 12, 15, 'A')
        box(6, 13, 9, 14, 'V'); box(5, 17, 6, 17, 'V'); box(9, 17, 10, 17, 'V')
    else: raise ValueError(name)
    return [''.join(row) for row in grid]

NAMES = ['DUCK','CUTE ANIMAL','BEANIE DEGEN','SENIOR DEV','PONYTAIL DEV','BOB BUILDER','VALIDATOR','ONCHAIN ARTIST','DAO SCOUT','SABADINHOS']


def render():
    shots = Path(__file__).resolve().parents[1] / 'shots'
    shots.mkdir(exist_ok=True)
    for theme,bg,fg in [('light',(246,245,240),(45,40,61)),('dark',(20,19,31),(246,245,240))]:
        frames=[]
        for lifted in (False,True):
            sheet=Image.new('RGB',(5*176,2*244),bg)
            d=ImageDraw.Draw(sheet)
            for n,name in enumerate(NAMES):
                x=(n%5)*176+4
                y0=(n//5)*244
                d.rounded_rectangle((x,y0+9,x+167,y0+191),radius=6,fill=(235,232,226))
                rows=sprite(name)
                if lifted: rows=rows[:12]+rows[13:]  # same row removed in main.lua
                im=Image.new('RGBA',(W,len(rows)))
                for y,row in enumerate(rows):
                    for col,ch in enumerate(row):im.putpixel((col,y),PALETTE[ch])
                scaled=im.resize((W*8,len(rows)*8),Image.Resampling.NEAREST)
                sheet.paste(scaled,(x+20,y0+28),scaled)
                d.text((x+8,y0+204),name,fill=fg)
            frames.append(sheet)
        frames[0].save(shots/f'character_study_{theme}.png')
        frames[0].save(shots/f'character_idle_{theme}.gif',save_all=True,append_images=[frames[1]],duration=[200,200],loop=0)
    print('rendered both theme sheets and 2-frame idle GIF studies')

if __name__=='__main__':
    if '--lua' in sys.argv:
        print('-- 16x18 original, outline-free characters, shared seafoam/peach/lavender palette.')
        print('local SKINS = {')
        for name in NAMES:
            print('  {name = "'+name+'", unlocked = '+('false' if name=='SABADINHOS' else 'true')+', sprite = {')
            print(',\n'.join('    "'+row+'"' for row in sprite(name)))
            print('  }},')
        print('}')
    else: render()

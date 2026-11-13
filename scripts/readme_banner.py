"""Generate the README poster from the project's own pixel-art studies."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'shots' / 'readme_banner.png'
W, H = 1280, 610
bg = (17, 17, 29)
purple = (171, 121, 255)
green = (20, 241, 149)
white = (248, 247, 250)
muted = (169, 169, 188)
im = Image.new('RGB', (W, H), bg)
d = ImageDraw.Draw(im)
font_dir = Path('C:/Windows/Fonts')
def font(name, size):
    return ImageFont.truetype(str(font_dir / name), size)

# Editorial typography; the only illustration is the project's SOL coin art.
d.text((64, 38), 'SOLANA BREAKPOINT BADGE  /  ARCADE', font=font('arialbd.ttf', 19), fill=green)
d.text((60, 95), 'SOL TO', font=font('arialbd.ttf', 94), fill=white)
d.text((60, 186), 'THE MOON', font=font('arialbd.ttf', 94), fill=white)
d.rounded_rectangle((64, 304, 510, 309), radius=2, fill=green)
d.text((64, 330), 'PUMP A SOL COIN', font=font('arialbd.ttf', 42), fill=white)
d.text((64, 380), 'ACROSS LONDON.', font=font('arialbd.ttf', 42), fill=purple)
d.text((66, 452), 'THREE KICKS   /   FOUR MAPS   /   NEARBY SCORES', font=font('arialbd.ttf', 18), fill=muted)

# Crop one frame from the two-frame original study, remove the black background
# and scale with nearest-neighbour to preserve the source's pixel grid.
coin = Image.open(ROOT / 'shots' / 'sol_coin_study.png').convert('RGBA').crop((0, 0, 50, 50))
pixels = coin.load()
for y in range(coin.height):
    for x in range(coin.width):
        r, g, b, _ = pixels[x, y]
        if max(r, g, b) < 35:
            pixels[x, y] = (r, g, b, 0)
coin = coin.resize((350, 350), Image.Resampling.NEAREST)
d.ellipse((849, 103, 1197, 451), outline=(76, 48, 117), width=3)
d.ellipse((874, 128, 1172, 426), outline=(48, 95, 86), width=2)
im.paste(coin, (850, 102), coin)

# Four actual map-art studies, kept as a contact strip rather than implied badge captures.
strip = Image.open(ROOT / 'shots' / 'map_study.png').convert('RGB')
for idx in range(4):
    x = idx * 320
    tile = strip.crop((x, 22, x + 320, 140)).resize((320, 128), Image.Resampling.NEAREST)
    im.paste(tile, (x, 482))
    d.rectangle((x, 480, x + 319, 609), outline=(43, 40, 60), width=1)
im.save(OUT, optimize=True)
print(OUT, im.size)

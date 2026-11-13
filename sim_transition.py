"""Scene changes must render directly, without a colour overlay."""
from pathlib import Path

src = Path(__file__).with_name('main.lua').read_text(encoding='utf-8')
assert 'swipe(' not in src, 'scene changes still trigger colour wipe'
assert 'sweep' not in src, 'colour overlay or timer still exists'
print('OK: direct scene rendering without colour wipe')

"""Regression for the badge's two-colour scene sweep geometry."""
import re
from pathlib import Path

src = Path(__file__).with_name('main.lua').read_text(encoding='utf-8')
widths = [int(re.search(r'local '+name+r' = ui\.rect\([^,]+, 0, (\d+), ui\.H', src).group(1)) for name in ('sweep', 'sweepEdge')]
assert min(widths) >= 32, f'thin stripe at midpoint: {widths}'
assert sum(widths) >= 160, f'scene wipe is too narrow: {widths}'
print('transition panel widths:', widths)

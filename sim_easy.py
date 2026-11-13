"""Fun pass: casual timing must reach the reward tiers far more often, rewards unchanged."""
import re
from pathlib import Path
import sim_fun

src = Path('main.lua').read_text(encoding='utf-8')
assert re.search(r'AWARD_MIN\s*=\s*600\b', src) and re.search(r'AWARD_BIG\s*=\s*800\b', src)
assert re.search(r'DAILY_LAMPS\s*=\s*20\b', src), 'reward system must stay 600/800/20'
for word in ('COMBO x2', 'MAX PUMP', 'm to 1 !LAMP', 'm to 5 !LAMPs', 'SO CLOSE', '100 M'):
    assert word in src, f'micro-incentive missing: {word}'

p600, p800, mean = sim_fun.rates(40, 8.0)
print(f'casual (8 px error): mean {mean:.0f} m, 600 m tier {p600:.0%}, 800 m tier {p800:.0%}')
# Before the fun pass the same player reached 600 m in 38% and 800 m in 15% of runs.
assert p600 >= 0.80, p600
assert p800 >= 0.45, p800
print('OK: casual players reach the !LAMP tiers; 600/800 m and 20 per day unchanged')

"""The published identifier must not reuse the Moonshot company name."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
NEW_ID = 'soltothemoon'
manifest = json.loads((ROOT / 'app.json').read_text(encoding='utf-8'))
assert manifest['id'] == NEW_ID, manifest['id']
assert 3 <= len(NEW_ID) <= 24 and all(c.islower() or c.isdigit() or c == '-' for c in NEW_ID)
assert len(manifest['name']) <= 20, manifest['name']

watched = ['main.lua', 'app.json', 'README.md', 'docs/DEVREL.md', 'docs/STORE_COPY.md',
           'sim.py', 'sim_rewards.py']
for rel in watched:
    text = (ROOT / rel).read_text(encoding='utf-8').lower()
    assert 'moonshot' not in text, f'{rel} still uses the old app id'
    assert 'moon shot' not in text, f'{rel} still uses the old award reason'
print('OK: app id is', NEW_ID, '- no "moonshot" left in app or docs')

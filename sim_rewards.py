"""Exercise per-run !LAMP rewards and the badge-local UTC day guard."""
import sim_env

_, G, _ = sim_env.load()
G.on_key('select', False)
clock = [1790000000]
G.sys.time = lambda: clock[0]


def finish(score):
    S = G._S
    S.mode = 'miss'
    S.swing = 3
    S.missT = 1
    S.total = score
    S.shots = G._store.get('test-shots') or S.shots
    G.on_tick(30)
    assert S.mode == 'end'


finish(799)
assert len(G._awards) == 1 and G._awards[-1][0] == 1, G._awards
for _ in range(4):
    finish(800)
assert [v[0] for v in G._awards] == [1, 5, 5, 5, 4], G._awards
finish(900)
assert len(G._awards) == 5, 'daily 20 cap must prevent another request'
clock[0] += 86400
finish(800)
assert G._awards[-1][0] == 5 and len(G._awards) == 6, G._awards
assert G._store['lampDay']['used'] == 5

# Failed or partial grants release the unused reservation; the OS server
# remains authoritative for all badges linked to the same X account.
requests = []
def partial_award(amount, reason, cb):
    requests.append(amount)
    cb(True, {'awarded': 2, 'balance': 0})
G.lamps.award = partial_award
finish(800)
assert requests == [5] and G._store['lampDay']['used'] == 7
G.lamps.award = lambda amount, reason, cb: cb(False, 'unavailable')
finish(800)
assert G._store['lampDay']['used'] == 7
print('OK: 800m earns up to 5 !LAMPs, 20 per synced UTC day on this badge')

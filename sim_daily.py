"""Daily layer: daily map with shared winds, three quests, day streak, today's best."""
import sim_env

DAY = 86400
L, G, keys = sim_env.load()
clock = [1790000000]
G.sys.time = lambda: clock[0]
store = G._store
S = G._S


def finish(score, map_daily=False):
    S.mode = 'miss'; S.swing = 3; S.missT = 1; S.total = score
    G.on_tick(30)
    assert S.mode == 'end'


day = clock[0] // DAY
daily = G._DAILY.state()
assert daily.day == day and len(list(daily.q.values())) == 3, 'three quests per day'
ids = list(daily.q.values())
assert len(set(ids)) == 3, 'quests must be distinct'
assert G._DAILY.map() == day % 4 + 1

# same winds on every badge for the daily map
def winds(seed):
    _, g, k = sim_env.load(seed=seed)
    g.sys.time = lambda: clock[0]
    for _ in range(g._DAILY.map() - 1):
        g.on_key('right', False)
    g.on_key('select', False)
    return g._S.wind
assert winds(1) == winds(99), 'daily map winds must match across badges'

G.on_key('select', False)
# streak: day 1, day 2 continue, skip a day resets
finish(500)
assert store.get('streak').n == 1
finish(700)
assert store.get('streak').n == 1, 'second run same day keeps the streak'
assert store.get('daily').best == 700 and store.get('daily').runs == 2
clock[0] += DAY
finish(300)
assert store.get('streak').n == 2 and store.get('daily').best == 300, 'new day: streak 2, today resets'
clock[0] += 2 * DAY
finish(300)
assert store.get('streak').n == 1, 'missed day resets the streak'

# quests complete once and pop
st = G._DAILY.state()
first = list(st.q.values())[0]
G._DAILY.quest(first)
assert st.done[first] is True
G._DAILY.quest(first)
n, total = G._DAILY.done()
assert (n, total) == (1, 3)
print('OK: daily map + shared winds, 3 distinct quests, streak, today best, quests')

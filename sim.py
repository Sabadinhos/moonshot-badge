"""Headless play-through of Moon Shot with scripted input."""
import random
import sim_env

L, G, keys = sim_env.load()
awards, log, store, objs = G._awards, G._log, G._store, G._objs
print("loaded; ui objects:", objs[0])

def tick(n=1):
    for _ in range(n): G.on_tick(30)

def state(): return G._S.mode

def play_swing(release_at_y):
    """hold select from the first tick, release when token y >= release_at_y"""
    keys["select"] = True
    while state() == "drop":
        tick()
        if G._S.token.y >= release_at_y: keys["select"] = False
    keys["select"] = False
    m = state(); n = 0
    while state() in ("flight", "miss", "result") and n < 3000:
        tick(); n += 1
    assert n < 3000, "swing never settled"
    return m, round(n * 0.03, 1), round(G._S.total)

random.seed(1)
assert state() == "title"
G.on_key("select", False); assert state() == "drop", state()
results = [play_swing(29), play_swing(20), play_swing(45)]
print("swings (mode, secs, total):", results)
print("final mode:", state(), "total:", round(G._S.total), "best:", store.get("best"), "awards:", awards)
print("hints/toasts:", [x for x in log if x[0] != "label"][-4:])
print("labels:", [x[1] for x in log if x[0] == "label"][-8:])

G.on_key("select", False); assert state() == "drop"
r2 = [play_swing(29) for _ in range(3)]
print("run2:", r2, "mode:", state(), "awards:", awards)
G.on_key("back", False); print("after back:", state())
assert state() == "title"
print("OK")

# ranks + sticks
G.on_key("up", False); assert state() == "ranks", state()
print("rank list:", [x for x in log if x[0] == "list"][-1])
G.on_key("back", False); assert state() == "title"
G.on_key("right", False); print("stick:", store.get("stick"), [x[1] for x in log if x[0]=="label"][-1])
G.on_key("right", False); print("stick:", store.get("stick"), [x[1] for x in log if x[0]=="label"][-1])
G.on_key("select", False); print("mode after select on stick 3 (best=%s):" % store.get("best"), state())
print("ranks stored:", store.get("ranks") and [dict(v.items()) for v in store.get("ranks").values()])
print("OK2")

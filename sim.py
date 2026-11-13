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
    """press to drop, hold for power, release near the bat"""
    while state() == "intro": tick()
    keys["select"] = False
    while state() == "ready" and not G._S.armed: tick()
    assert state() == "ready" and G._S.token.y == -8
    keys["select"] = True
    G.on_key("select", False)
    assert state() == "drop" and G._S.charging
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
assert any(x == ("label", "SOL TO THE MOON") for x in log), "new title must render immediately"
assert store.get("stage1Done") is None
G.on_key("right", False)
assert store.get("map") == 2, "RIGHT should cycle map without starting the game"
G.on_key("right", False); assert store.get("map") == 3
G.on_key("right", False); assert store.get("map") == 4, "Olympia must be selectable"
assert any(x == ("label", "< OLYMPIA >") for x in log)
G.on_key("right", False); assert store.get("map") == 1, "map selection must wrap"
G.on_key("right", False); assert store.get("map") == 2
assert any(x == ("label", "< TOWER BRIDGE >") for x in log)
tick(2)
G.on_key("up", False)  # wraps past the hidden skin
assert store.get("skin") == 9, "hidden skin must be skipped before stage 1 is done"
G.on_key("left", False); assert store.get("map") == 1, "LEFT selects the previous map"
G.on_key("left", False); assert store.get("map") == 4, "LEFT wraps from first to last map"
G.on_key("right", False); assert store.get("map") == 1
G.on_key("right", False); assert store.get("map") == 2
G.on_key("select", False); assert state() == "intro", state()
keys["select"] = True  # nervous player holds/mashes during the fly-in
G.on_key("select", False)
tick(21); assert state() == "ready", "fly-in must lead to a protected ready state"
tick(40); assert state() == "ready" and G._S.token.y == -8, "held input must not consume a kick"
keys["select"] = False
tick(14); assert state() == "ready", "release needs a brief calm beat"
tick(1); assert state() == "ready" and G._S.armed and G._S.token.y == -8
assert G._S.map == 2, "selected scene must carry into gameplay"
results = [play_swing(43)]
assert state() == "intro", "second kick should have its own fly-in"
keys["select"] = True
for _ in range(3): G.on_key("select", False)
tick(26)
assert state() == "ready" and G._S.swing == 2 and G._S.token.y == -8
keys["select"] = False
results.extend([play_swing(36), play_swing(60)])
assert store.get("stage1Done") is True, "Sabadinhos skin should unlock after stage 1"
G.on_key("back", False); assert state() == "title"
G.on_key("down", False); assert store.get("skin") == 10, "Sabadinhos should be selectable after stage 1"
G.on_key("select", False); assert state() == "intro", "unlocked skin should launch immediately"
G.on_key("back", False); assert state() == "pause"
G.on_key("down", False); assert state() == "title"
print("swings (mode, secs, total):", results)
print("final mode:", state(), "total:", round(G._S.total), "best:", store.get("best"), "awards:", awards)
print("hints/toasts:", [x for x in log if x[0] != "label"][-4:])
print("labels:", [x[1] for x in log if x[0] == "label"][-8:])

G.on_key("select", False); assert state() == "intro"
r2 = [play_swing(43) for _ in range(3)]
print("run2:", r2, "mode:", state(), "awards:", awards)
assert state() == "end"
assert len(G._S.shots) == 3 and sum(G._S.shots.values()) == int(G._S.total), "all kick scores must be on the result"
assert G._S.celebrate > 0, "end scene confetti must begin"
assert any(x[0] == "label" and "KICK 1" in x[1] for x in log), "end scene must show individual kicks"
tick(100); assert G._S.celebrate == 0, "confetti must stop instead of burning CPU"
G.on_key("select", False); assert state() == "intro" and len(G._S.shots) == 0, "replay must reset kick stats"
G.on_key("back", False); assert state() == "pause"
G.on_key("down", False); assert state() == "title"
G.on_key("select", False); assert state() == "intro"
[play_swing(43) for _ in range(3)]
assert state() == "end"
G.on_key("down", False); assert store.get("stick") == 2
G.on_key("down", False); assert store.get("stick") == 1, "locked Ledger must be skipped"
G.on_mesh("FRIEND1", L.table(kind="moonshot-score", value=777))
assert store.get("peers")["FRIEND1"]["name"] == "@friend"
G.on_mesh("FRIEND1", L.table(kind="moonshot-score", value=600))
assert store.get("peers")["FRIEND1"]["score"] == 777, "peer personal best must not decrease"
G.on_mesh("BAD1111", L.table(kind="moonshot-score", value=999999))
G.on_mesh("BAD2222", L.table(kind="moonshot-score", value=123.5))
G.on_mesh("7K2Q9M", L.table(kind="moonshot-score", value=999))
assert store.get("peers")["BAD1111"] is None and store.get("peers")["BAD2222"] is None
assert store.get("peers")["7K2Q9M"] is None
G.on_key("up", False); assert state() == "ranks", state()
assert any(i.get("title", "").endswith("@friend") for x in log if x[0] == "list" for i in x[1])
print("rank list:", [x for x in log if x[0] == "list"][-1])
for i in range(5):
    G.on_mesh("PEER" + str(i), L.table(kind="moonshot-score", value=900 + i))
items = [x for x in log if x[0] == "list"][-1][1]
assert len(items) == 5 and any("YOU" in item["title"] for item in items)
assert any("7.  YOU" == item["title"] for item in items), items
G.on_key("back", False); assert state() == "title"
print("OK")

# DOWN on title moves the character, while the selected bat persists after the result screen.
old_skin = store.get("skin")
G.on_key("down", False); assert store.get("stick") == 1 and store.get("skin") != old_skin
G.on_key("select", False); print("mode after replay (best=%s):" % store.get("best"), state())
print("ranks stored:", store.get("ranks") and [dict(v.items()) for v in store.get("ranks").values()])
print("OK2")

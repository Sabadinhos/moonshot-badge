"""Final public controls: map/character arrows and press-to-start timing."""
from sim_env import load

L, g, keys = load(seed=13)

def tick(n=1):
    for _ in range(n):
        g.on_tick(30)

assert g._S.mode == "title"
g.on_key("right", False)
assert g._store["map"] == 2 and g._store.get("skin", 1) == 1

g.on_key("left", False)
assert g._store["map"] == 1
g.on_key("down", False)
assert g._store["skin"] == 2 and g._store["map"] == 1
g.on_key("up", False)
assert g._store["skin"] == 1

g.on_key("select", False)
assert g._S.mode == "intro"
keys["select"] = True
tick(22)
assert g._S.mode == "ready"
tick(50)
assert g._S.mode == "ready" and g._S.token.y == -8
keys["select"] = False
tick(17)
assert g._S.mode == "ready" and g._S.armed
# It must not fall until a fresh SELECT press, even after a long idle.
tick(150)
assert g._S.mode == "ready" and g._S.token.y == -8 and g._S.swing == 1
assert any(x == ("label", "HOLD SELECT") for x in g._log)
keys["select"] = True
g.on_key("select", False)
assert g._S.mode == "drop" and g._S.charging and g._S.token.y == -8
tick(5)
assert g._S.token.y > -8 and g._S.power > 0
while g._S.token.y < 43:
    tick()
keys["select"] = False
tick()
assert g._S.mode == "flight", "release near the bat should launch"
for _ in range(1000):
    if g._S.mode == "intro":
        break
    tick()
assert g._S.mode == "intro" and g._S.swing == 2

# A tap that releases while the coin is still high must not create negative flight speed.
L2, g2, keys2 = load(seed=13)
g2.on_key("select", False)
for _ in range(21): g2.on_tick(30)
assert g2._S.mode == "ready"
for _ in range(15): g2.on_tick(30)
assert g2._S.armed
keys2["select"] = True
g2.on_key("select", False)
keys2["select"] = False
g2.on_tick(30)
assert g2._S.mode == "miss" and g2._S.flight is None
print("OK: arrows, release-to-arm, press-to-drop, held kick, early-tap safety")

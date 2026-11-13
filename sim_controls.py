"""CANCEL/pause/quit and fast-transition regression checks."""
from sim_env import load


def tick(g, n=1):
    for _ in range(n):
        g.on_tick(30)


L, g, keys = load(seed=7)
assert g._S.mode == "title"
assert g.on_key("back", False) is True
assert g._S.mode == "quit", "CANCEL on title must confirm instead of exiting"
tick(g, 20)
g.on_key("left", False)
assert g._S.mode == "quit", "unrelated keys must not confirm quit"
g.on_key("back", False)
assert g._S.mode == "title", "CANCEL in confirmation must stay"

g.on_key("select", False)
assert g._S.mode == "intro"
tick(g, 8)
intro_time = g._S.introT
assert g.on_key("back", False) is True
assert g._S.mode == "pause", "CANCEL during a run must pause"
tick(g, 100)
assert g._S.mode == "pause" and g._S.introT == intro_time
assert g._S.swing == 1 and g._S.total == 0

g.on_key("back", False)
assert g._S.mode == "intro", "CANCEL while paused should resume"
while g._S.mode == "intro":
    tick(g)
keys["select"] = False
while g._S.mode == "ready" and not g._S.armed:
    tick(g)
assert g._S.mode == "ready" and g._S.token.y == -8
keys["select"] = True
g.on_key("select", False)
assert g._S.mode == "drop"
tick(g, 4)
assert g._S.charging and g._S.power > 0
frozen_y = g._S.token.y
g.on_key("back", False)
assert g._S.mode == "pause"
tick(g, 100)
assert g._S.token.y == frozen_y and g._S.swing == 1

g.on_key("right", False)
assert g._S.mode == "quit", "quitting from pause needs another confirmation"
g.on_key("back", False)
assert g._S.mode == "pause"
g.on_key("select", False)
assert g._S.mode == "ready" and g._S.token.y == -8 and not g._S.charging
# A held resume press cannot turn into a hit.
tick(g, 30)
assert g._S.mode == "ready" and g._S.swing == 1
keys["select"] = False
tick(g, 15)
assert g._S.mode == "ready" and g._S.armed and g._S.token.y == -8
keys["select"] = True
g.on_key("select", False)
assert g._S.mode == "drop" and g._S.charging
while g._S.token.y < 43:
    tick(g)
keys["select"] = False
tick(g)
assert g._S.mode == "flight", "normal kick must still launch"
x = g._S.flight.x
g.on_key("back", False)
assert g._S.mode == "pause"
tick(g, 100)
assert g._S.flight.x == x, "flight must freeze while paused"
g.on_key("select", False)
assert g._S.mode == "flight"
tick(g, 1)
assert g._S.flight.x != x, "flight must continue after resume"

g.on_key("back", False)
assert g._S.mode == "pause"
g.on_key("down", False)
assert g._S.mode == "title", "leave-run action must be deliberate"
g.on_key("back", False)
assert g._S.mode == "quit"
g.on_key("select", False)
assert g._S.mode == "title"
g.on_key("back", False)
assert g._S.mode == "quit"
g.on_key("right", False)
assert ("exit",) in g._log, "only a confirmed RIGHT should call sys.exit"
print("OK: title confirmation, frozen pause, safe resume, two-step quit")

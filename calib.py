"""Calibration sweep: distance and flight time vs power, timing and wind."""
import statistics, sys
import sim_env

def run_case(power, dy, wind, seed=0):
    L, G, keys = sim_env.load(seed=seed)
    G.on_key("select", False)
    S = G._S
    assert S.mode == "intro"
    S.mode = "drop"  # skip only the intro; keep calibrated gameplay physics
    S.wind = wind; S.power = power
    S.wait = 0
    S.token.y = 47 - 4 + dy
    S.charging = True
    keys["select"] = False
    G.on_tick(30)
    n = 0
    while S.mode == "flight" and n < 2000:
        G.on_tick(30); n += 1
    return (round(S.flight.x) if S.flight else 0, round(n * 0.03, 1))

N = int(sys.argv[1]) if len(sys.argv) > 1 else 12
print("power  dy  wind -> dist mean (min..max)  secs mean/max")
for power in (30, 60, 100):
    for dy in (0, -4, 4):
        for wind in (-6, 0, 6):
            ds = [run_case(power, dy, wind, s) for s in range(N)]
            dist = [d[0] for d in ds]; secs = [d[1] for d in ds]
            print(f"{power:4} {dy:4} {wind:4} -> {statistics.mean(dist):6.0f} ({min(dist)}..{max(dist)})  {statistics.mean(secs):4.1f}s / {max(secs)}s")

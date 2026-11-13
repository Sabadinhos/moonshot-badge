"""Casual-player model: full 3-kick runs with human timing error.

Reports how often a casual player reaches the 600 m (1 !LAMP) and 800 m (5 !LAMPs) tiers.
Usage: python sim_fun.py [runs] [sigma_px]
"""
import random
import sys
import sim_env

HIT_Y = 47


def run(seed, sigma):
    rng = random.Random(seed * 7919)
    L, G, keys = sim_env.load(seed=seed)
    S = G._S
    G.on_key('select', False)
    for _ in range(3):
        while S.mode == 'intro':
            G.on_tick(30)
        keys['select'] = False
        while S.mode == 'ready' and not S.armed:
            G.on_tick(30)
        err = rng.gauss(0, sigma)
        keys['select'] = True
        G.on_key('select', False)
        while S.mode == 'drop':
            G.on_tick(15)
            if keys['select'] and S.token.y + 4 - HIT_Y >= err:
                keys['select'] = False
        keys['select'] = False
        n = 0
        start = S.swing
        while S.mode in ('flight', 'miss', 'result') and S.swing == start and n < 4000:
            G.on_tick(30)
            n += 1
    while S.mode != 'end':
        G.on_tick(30)
    return int(S.total)


def rates(runs=60, sigma=5.0):
    totals = [run(s + 1, sigma) for s in range(runs)]
    p600 = sum(t >= 600 for t in totals) / runs
    p800 = sum(t >= 800 for t in totals) / runs
    return p600, p800, sum(totals) / runs


if __name__ == '__main__':
    runs = int(sys.argv[1]) if len(sys.argv) > 1 else 60
    sigma = float(sys.argv[2]) if len(sys.argv) > 2 else 5.0
    p600, p800, mean = rates(runs, sigma)
    print(f'casual sigma {sigma}px over {runs} runs: mean {mean:.0f} m, >=600 m {p600:.0%}, >=800 m {p800:.0%}')

"""Balance: a perfectly timed hold must be able to reach the moon and the 800 m tier."""
import sim_env


def kick(release_dy, wind=0):
    """Press at the armed ready state; release when the coin is release_dy px from the bat line."""
    L, G, keys = sim_env.load(seed=1)
    S = G._S
    G.on_key('select', False)
    while S.mode == 'intro':
        G.on_tick(30)
    keys['select'] = False
    while S.mode == 'ready' and not S.armed:
        G.on_tick(30)
    S.wind = wind
    keys['select'] = True
    G.on_key('select', False)
    hit_y = 47  # HIT_Y in main.lua; the coin's centre is token.y + 4
    while S.mode == 'drop':
        G.on_tick(10)
        if S.token.y + 4 - hit_y >= release_dy:
            keys['select'] = False
    keys['select'] = False
    G.on_tick(10)
    power = S.power
    n = 0
    while S.mode == 'flight' and n < 3000:
        G.on_tick(30)
        n += 1
    return power, (S.shots[1] or 0)


power, dist = kick(0)
print(f'perfect release, no wind: power {power:.0f}, {dist} m')
assert power >= 95, f'perfect timing only reaches power {power:.0f}'
assert dist * 3 >= 800, f'three perfect kicks make {dist * 3} m, the 800 m tier is out of reach'
_, tail = kick(0, wind=6)
print(f'perfect release, tailwind 6: {tail} m')
assert tail >= 400, f'perfect kick with tailwind lands {tail} m, the moon (400 m) is out of reach'

early_power, early = kick(-6)
late_power, late = kick(5)
print(f'early: power {early_power:.0f} {early} m; late: power {late_power:.0f} {late} m')
assert early < dist and late < dist, 'timing must still matter'
print('OK: perfect timing reaches the moon; 800 m over three kicks is reachable')

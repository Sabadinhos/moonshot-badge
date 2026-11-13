"""Stub of the Solana OS Lua API for headless tests of main.lua."""
import os
from lupa import LuaRuntime


def load(seed=None):
    L = LuaRuntime(unpack_returned_tuples=True)
    G = L.globals()
    if seed is not None: G.SEED = seed
    keys = {"select": False}
    log, objs, awards, store = [], [0], [], {}

    def noop(*a): return None

    def mk_label(x, y, text, opts=None):
        objs[0] += 1
        t = L.table()
        t.text = lambda self, s: log.append(("label", s))
        for n in ("pos", "color", "show", "remove"): t[n] = noop
        return t

    def mk_rect(*a):
        objs[0] += 1
        t = L.table()
        for n in ("pos", "size", "color", "show", "remove"): t[n] = noop
        return t

    def mk_bar(x, y, w, h, v):
        objs[0] += 1
        t = L.table()
        t.set = ints("bar:set")
        t.remove = lambda self: objs.__setitem__(0, objs[0] - 1)
        return t

    def ints(name):
        def f(self, *a):
            for v in a:
                if isinstance(v, float) and not v.is_integer(): raise TypeError(f"{name}: non-integer {v}")
        return f

    def mk_canvas(x, y, w, h, opts=None):
        objs[0] += 1
        t = L.table()
        for n in ("clear", "pixel", "rect", "line", "pos", "show", "remove"): t[n] = ints("canvas:" + n)
        def image(self, img, x, y):
            assert img is not None, "canvas:image got nil"
            ints("canvas:image")(self, x, y)
        t.image = image
        return t

    def mk_list(x, y, w, h, items, opts=None):
        objs[0] += 1
        log.append(("list", [dict(i.items()) if hasattr(i, "items") else i for i in items.values()]))
        t = L.table()
        for n in ("items", "select", "remove"): t[n] = noop
        t.selected = lambda self: 1
        return t

    def ui_load(rows, opts=None):
        pal = set("# kwpgmvbaloy.")
        if opts is not None and opts["palette"] is not None:
            pal |= set(opts["palette"].keys())
        for r in rows.values():
            for ch in r:
                if ch not in pal: raise ValueError(f"bad palette char {ch!r} in row {r!r}")
        return L.table(rows=rows)

    G.ui = L.table(W=320, H=218, label=mk_label, rect=mk_rect, bar=mk_bar, canvas=mk_canvas, load=ui_load, list=mk_list,
                   bg=noop, hint=lambda s: log.append(("hint", s)), toast=lambda s: log.append(("toast", s)))
    G.storage = L.table(get=lambda k: store.get(k), set=lambda k, v: store.__setitem__(k, v),
                        remove=lambda k: store.pop(k, None))
    G.led = L.table(count=8, set=noop, hex=noop, fill=noop, off=noop)
    G.badge = L.table(owner=lambda: "@tester", id=lambda: "7K2Q9M")
    G.mesh = L.table(send=lambda to, msg: log.append(("mesh", to, msg["value"])),
                     nearby=lambda: L.table_from([L.table(id="FRIEND1", name="@friend", level=42)]))
    G.sys = L.table(keys=lambda: L.table(select=keys["select"]), millis=lambda: 0,
                    exit=lambda: log.append(("exit",)))

    def award(amount, reason, cb):
        awards.append((amount, reason))
        cb(True, L.table(awarded=amount, balance=100))
    G.lamps = L.table(award=award)
    G.timer = L.table(after=lambda ms, fn: 1, every=lambda ms, fn: 1, cancel=noop)

    src = open(os.path.join(os.path.dirname(__file__), "main.lua"), encoding="utf-8").read()
    L.execute(src)
    G._awards, G._log, G._store, G._objs = awards, log, store, objs
    return L, G, keys

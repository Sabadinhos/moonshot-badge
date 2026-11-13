"""Rasterising stub of the Solana OS UI, so main.lua can be rendered headlessly.

This renders the app's own draw calls into images. It approximates the badge
screen (fonts and anti-aliasing differ) and is NOT a badge capture.
"""
import os

from lupa import LuaRuntime
from PIL import Image, ImageDraw, ImageFont

W, H = 320, 218
THEME = {
    'bg': 0x11111D, 'text': 0xF8F7FA, 'dim': 0xA9A9BC, 'green': 0x14F195,
    'purple': 0xAB79FF, 'pink': 0xFF6B9D, 'orange': 0xFFA14A, 'lime': 0x8CF58C,
    'yellow': 0xF5D76E,
}
FONT_DIR = 'C:/Windows/Fonts'


def rgb(color, default=0x000000):
    if color is None:
        return None
    if isinstance(color, str):
        color = THEME.get(color, default)
    color = int(color)
    return ((color >> 16) & 255, (color >> 8) & 255, color & 255)


def _font(size):
    return ImageFont.truetype(os.path.join(FONT_DIR, 'arialbd.ttf'), max(9, int(size * 0.82)))


class Canvas:
    def __init__(self, x, y, w, h, scale, color):
        self.x, self.y, self.w, self.h, self.scale = x, y, w, h, scale
        self.base = rgb(color, 0x11111D)
        self.visible = True
        self.im = Image.new('RGB', (w, h), self.base)
        self.d = ImageDraw.Draw(self.im)

    def clear(self, color=None):
        self.d.rectangle((0, 0, self.w, self.h), fill=rgb(color) or self.base)

    def pixel(self, x, y, color):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.im.putpixel((int(x), int(y)), rgb(color))

    def rect(self, x, y, w, h, color):
        if w > 0 and h > 0:
            self.d.rectangle((int(x), int(y), int(x + w - 1), int(y + h - 1)), fill=rgb(color))

    def line(self, x1, y1, x2, y2, color):
        self.d.line((int(x1), int(y1), int(x2), int(y2)), fill=rgb(color))

    def image(self, img, x, y):
        assert img is not None, 'canvas:image got nil'
        assert isinstance(img, Img), f'canvas:image got {type(img)}'
        rows, pal = img.rows, img.pal
        for dy, row in enumerate(rows):
            for dx, ch in enumerate(row):
                if ch == '.':
                    continue
                self.pixel(int(x) + dx, int(y) + dy, pal.get(ch, 0xFF00FF))


class Img:
    """Opaque sprite handle. A tuple would be unpacked into multiple Lua values."""

    def __init__(self, rows, pal):
        self.rows, self.pal = rows, pal


class Label:
    def __init__(self, x, y, text, opts):
        self.x, self.y, self.text_value = x, y, text or ''
        opts = opts or {}
        self.size = opts.get('size') or 14
        self.color = opts.get('color') or 'text'
        self.w = opts.get('w')
        self.align = opts.get('align') or 'left'
        self.visible = True


class Rect:
    def __init__(self, x, y, w, h, opts):
        self.x, self.y, self.w, self.h = x, y, w, h
        self.color = (opts or {}).get('color') or 'dim'
        self.visible = True


class Bar:
    def __init__(self, x, y, w, h, v):
        self.x, self.y, self.w, self.h, self.value = x, y, w, h, v
        self.visible = True


def load(seed=None):
    """Load main.lua against the rasterising stub. Returns (lua, globals, keys, scene)."""
    L = LuaRuntime(unpack_returned_tuples=True)
    G = L.globals()
    if seed is not None:
        G.SEED = seed
    keys = {'select': False}
    store, awards, log = {}, [], []
    scene = {'canvases': [], 'labels': [], 'rects': [], 'bars': [], 'hint': '', 'bg': 'bg'}

    def opts_of(opts):
        return dict(opts.items()) if opts is not None and hasattr(opts, 'items') else {}

    def wrap(obj, extra=None):
        t = L.table()

        def show(self, visible=True):
            obj.visible = bool(visible)
        t.show = show
        t.remove = lambda self: setattr(obj, 'visible', False)

        def pos(self, x, y):
            obj.x, obj.y = x, y
        t.pos = pos
        t.size = lambda self, *a: None
        t.color = lambda self, c: setattr(obj, 'color', c)
        for name, fn in (extra or {}).items():
            t[name] = fn
        return t

    def mk_canvas(x, y, w, h, opts=None):
        o = opts_of(opts)
        c = Canvas(x, y, w, h, o.get('scale') or 1, o.get('color'))
        scene['canvases'].append(c)
        extra = {n: (lambda self, *a, n=n: getattr(c, n)(*a))
                 for n in ('clear', 'pixel', 'rect', 'line', 'image')}
        return wrap(c, extra)

    def mk_label(x, y, text, opts=None):
        lb = Label(x, y, text, opts_of(opts))
        scene['labels'].append(lb)
        return wrap(lb, {'text': lambda self, s: setattr(lb, 'text_value', s)})

    def mk_rect(x, y, w, h, opts=None):
        r = Rect(x, y, w, h, opts_of(opts))
        scene['rects'].append(r)
        return wrap(r)

    def mk_bar(x, y, w, h, v):
        b = Bar(x, y, w, h, v)
        scene['bars'].append(b)
        return wrap(b, {'set': lambda self, v: setattr(b, 'value', v)})

    def mk_list(x, y, w, h, items, opts=None):
        rows = [dict(i.items()) if hasattr(i, 'items') else i for i in items.values()]
        log.append(('list', rows))
        scene['list'] = rows
        t = wrap(Rect(x, y, w, h, None))
        t.items = lambda self, *a: None
        t.select = lambda self, *a: None
        t.selected = lambda self: 1
        return t

    def ui_load(rows, opts=None):
        pal = dict(THEME)
        o = opts_of(opts)
        if o.get('palette') is not None:
            pal.update({k: v for k, v in o['palette'].items()})
        resolved = {k: (THEME[v] if isinstance(v, str) else v) for k, v in pal.items()}
        return Img(list(rows.values()), resolved)

    G.ui = L.table(W=W, H=H, label=mk_label, rect=mk_rect, bar=mk_bar, canvas=mk_canvas,
                   load=ui_load, list=mk_list,
                   bg=lambda c: scene.__setitem__('bg', c),
                   hint=lambda s: scene.__setitem__('hint', s),
                   toast=lambda s: log.append(('toast', s)))
    G.storage = L.table(get=lambda k: store.get(k), set=lambda k, v: store.__setitem__(k, v),
                        remove=lambda k: store.pop(k, None))
    G.led = L.table(count=8, set=lambda *a: None, hex=lambda *a: None,
                    fill=lambda *a: None, off=lambda *a: None)
    G.badge = L.table(owner=lambda: '@sabadinhos', id=lambda: '7K2Q9M')
    G.mesh = L.table(send=lambda to, msg: None,
                     nearby=lambda: L.table_from([L.table(id='FRIEND1', name='@friend', level=42)]))
    G.sys = L.table(keys=lambda: L.table(select=keys['select']), millis=lambda: 0,
                    time=lambda: 1790000000, exit=lambda: log.append(('exit',)))
    G.lamps = L.table(award=lambda amount, reason, cb: (awards.append((amount, reason)),
                                                        cb(True, L.table(awarded=amount, balance=1)))[1])
    G.timer = L.table(after=lambda ms, fn: 1, every=lambda ms, fn: 1, cancel=lambda *a: None)

    src = open(os.path.join(os.path.dirname(__file__), 'main.lua'), encoding='utf-8').read()
    L.execute(src)
    G._awards, G._log, G._store, G._scene = awards, log, store, scene
    return L, G, keys, scene


def frame(scene, upscale=2):
    """Compose one screen image from the current scene state."""
    im = Image.new('RGB', (W, H), rgb(scene['bg'], 0x11111D))
    d = ImageDraw.Draw(im)
    for c in scene['canvases']:
        if c.visible:
            im.paste(c.im.resize((c.w * c.scale, c.h * c.scale), Image.Resampling.NEAREST),
                     (c.x, c.y))
    for r in scene['rects']:
        if r.visible:
            d.rectangle((r.x, r.y, r.x + r.w, r.y + r.h), fill=rgb(r.color))
    for b in scene['bars']:
        if b.visible:
            d.rectangle((b.x, b.y, b.x + b.w, b.y + b.h), fill=(40, 40, 58))
            fill_w = int(b.w * max(0, min(100, b.value or 0)) / 100)
            if fill_w:
                d.rectangle((b.x, b.y, b.x + fill_w, b.y + b.h), fill=rgb('green'))
    for lb in scene['labels']:
        if not lb.visible or not lb.text_value:
            continue
        f = _font(lb.size)
        tw = d.textlength(lb.text_value, font=f)
        x = lb.x
        if lb.w and lb.align == 'center':
            x = lb.x + (lb.w - tw) / 2
        elif lb.w and lb.align == 'right':
            x = lb.x + lb.w - tw
        d.text((x, lb.y), lb.text_value, font=f, fill=rgb(lb.color, 0xF8F7FA))
    if scene['hint']:
        f = _font(11)
        tw = d.textlength(scene['hint'], font=f)
        d.rectangle((0, H - 15, W, H), fill=(22, 22, 34))
        d.text(((W - tw) / 2, H - 14), scene['hint'], font=f, fill=rgb('dim'))
    if upscale != 1:
        im = im.resize((W * upscale, H * upscale), Image.Resampling.NEAREST)
    return im

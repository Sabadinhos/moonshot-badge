"""Approximate 320x218 menu composition study; not an emulator screenshot."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from map_art import MAPS, COLORS, scene
from character_art import sprite, PALETTE

ROOT=Path(__file__).resolve().parents[1]
FONT='C:/Windows/Fonts/arial.ttf'

def f(size,bold=False):
 p='C:/Windows/Fonts/arialbd.ttf' if bold else FONT
 return ImageFont.truetype(p,size)

def col(s):return tuple(bytes.fromhex(s[2:]))

def center(d,txt,y,font,color,x0=0,x1=320):
 w=d.textbbox((0,0),txt,font=font)[2];d.text((x0+(x1-x0-w)//2,y),txt,font=font,fill=color)

def tile(im,rows,pal,x,y):
 for yy,row in enumerate(rows):
  for xx,k in enumerate(row):
   if k=='.':continue
   c=pal[k]
   if isinstance(c,str):c=col(c)
   ImageDraw.Draw(im).rectangle((x+xx*4,y+yy*4,x+xx*4+3,y+yy*4+3),fill=c)

out=Image.new('RGB',(960,436))
for theme in range(2):
 for i,mapname in enumerate(MAPS):
  bg=(247,246,243) if theme==0 else (20,21,30)
  ink=(38,37,48) if theme==0 else (244,241,248)
  muted=(102,100,114) if theme==0 else (177,169,192)
  purple=(103,68,165) if theme==0 else (188,163,247)
  im=Image.new('RGB',(320,218),bg);d=ImageDraw.Draw(im)
  c=COLORS[i]
  d.rectangle((0,44,319,131),fill=col(c['menu']))
  d.rectangle((8,48,151,127),fill=col(c['sky']))
  d.rectangle((168,48,311,127),fill=(235,232,226))
  rows=scene(mapname)
  thumb=[''.join(row[x-1] for x in range(4,71,2)) for row in rows]
  tile(im,thumb,c,12,56)
  name=['DUCK','PONYTAIL DEV','VALIDATOR'][i]
  tile(im,sprite(name),PALETTE,208,52)
  d=ImageDraw.Draw(im)
  center(d,'SOL TO THE MOON',4,f(27,True),ink)
  center(d,'MAP',36,f(11,True),muted,0,160)
  center(d,'CHARACTER',36,f(11,True),muted,160,320)
  center(d,'UP  '+mapname,129,f(13,True),purple,0,160)
  center(d,'< '+name+' >',129,f(13,True),purple,160,320)
  center(d,'DOWN  BROLLY  /  balanced',154,f(14),muted)
  d.rounded_rectangle((74,175,246,203),radius=6,fill=(72,174,148))
  center(d,'SELECT  PLAY',178,f(20,True),(255,255,255))
  out.paste(im,(i*320,theme*218))
out.save(ROOT/'shots'/'menu_maps_study.png')
print(ROOT/'shots'/'menu_maps_study.png')

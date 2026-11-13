"""Approximate 320x218 menu composition study; not an emulator screenshot."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
from map_art import MAPS, COLORS, icon
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

out=Image.new('RGB',(len(MAPS)*320,436))
for theme in range(2):
 for i,mapname in enumerate(MAPS):
  bg=(247,246,243) if theme==0 else (20,21,30)
  ink=(38,37,48) if theme==0 else (244,241,248)
  muted=(102,100,114) if theme==0 else (177,169,192)
  purple=(103,68,165) if theme==0 else (188,163,247)
  im=Image.new('RGB',(320,218),bg);d=ImageDraw.Draw(im)
  c=COLORS[i]
  icon_pal={'d':purple,'s':(72,174,148),'l':muted,'c':(219,175,103)}
  tile(im,icon(mapname),icon_pal,32,56)
  d.rectangle((200,52,279,123),fill=col(c['menu']))
  name=['DUCK','PONYTAIL DEV','VALIDATOR','CUTE ANIMAL'][i]
  tile(im,sprite(name)[:12],PALETTE,208,64)
  d=ImageDraw.Draw(im)
  center(d,'SOL TO THE MOON',4,f(27,True),ink)
  center(d,'MAP',36,f(11,True),muted,0,160)
  center(d,'CHARACTER',36,f(11,True),muted,160,320)
  center(d,'< '+mapname+' >',129,f(13,True),purple,0,160)
  center(d,'^v  '+name,129,f(13,True),purple,160,320)
  center(d,'BAT  BROLLY  /  balanced',154,f(14),muted)
  d.rounded_rectangle((74,175,246,203),radius=6,fill=(72,174,148))
  center(d,'SELECT  PLAY',178,f(20,True),(255,255,255))
  out.paste(im,(i*320,theme*218))
out.save(ROOT/'shots'/'menu_final_study.png')
print(ROOT/'shots'/'menu_final_study.png')

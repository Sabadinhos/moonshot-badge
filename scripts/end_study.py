"""Approximate result layout study, not a badge screenshot."""
from PIL import Image,ImageDraw,ImageFont
from pathlib import Path
from token_art import coin
FONT='C:/Windows/Fonts/arial.ttf'
BOLD='C:/Windows/Fonts/arialbd.ttf'
def font(n,b=False):return ImageFont.truetype(BOLD if b else FONT,n)
def center(d,text,y,size,color,x=0,w=320,b=False):
 f=font(size,b);tw=d.textbbox((0,0),text,font=f)[2]
 d.text((x+(w-tw)//2,y),text,font=f,fill=color)
colors={'.':None,'y':'#DABE86','k':'#272337','e':'#31CFA7','b':'#9B6AEA','w':'#FFF9DA'}
out=Image.new('RGB',(640,218))
for theme in range(2):
 bg='#F7F6F3' if theme==0 else '#14151E';ink='#262530' if theme==0 else '#F4F1F8';muted='#666472' if theme==0 else '#B1A9C0';purple='#6744A5' if theme==0 else '#BCA3F7'
 im=Image.new('RGB',(320,218),bg);d=ImageDraw.Draw(im)
 center(d,'OLYMPIA / DUCK',2,12,muted)
 center(d,'BRILLIANT',20,20,'#48AE94',b=True)
 center(d,'1025 m',50,32,ink,b=True)
 center(d,'NEW PERSONAL BEST   RANK #1',90,14,muted)
 for i in range(3):
  for y,row in enumerate(coin()):
   for x,c in enumerate(row):
    if c!='.':d.rectangle((32+i*108+x*4,108+y*4,35+i*108+x*4,111+y*4),fill=colors[c])
 center(d,'KICK 1        KICK 2        KICK 3',151,12,muted)
 for i,v in enumerate((416,305,304)):center(d,str(v)+' m',170,20,purple,i*107,106,True)
 for i in range(16):
  x=(i*23)%78*4;y=(-((i*7)%23)+23)*4
  if 0<=y<200:d.rectangle((x,y,x+7,y+3),fill=('#14F195','#9945FF','#DCC49D')[i%3])
 out.paste(im,(theme*320,0))
p=Path(__file__).resolve().parents[1]/'shots'/'end_study.png';out.save(p);print(p)

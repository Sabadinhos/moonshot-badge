"""Subtle London map silhouettes, 80x17 pixel strips (original art)."""
from PIL import Image, ImageDraw
from pathlib import Path
W,H=80,17

def scene(kind):
 g=[['.']*W for _ in range(H)]
 def box(x1,y1,x2,y2,c):
  for y in range(max(0,y1),min(H,y2+1)):
   for x in range(max(0,x1),min(W,x2+1)):g[y][x]=c
 def dot(x,y,c):box(x,y,x,y,c)
 if kind=='WESTMINSTER':
  # Big Ben and the long stepped Parliament roofline; one warm clock pixel.
  box(0,12,50,16,'d');box(2,10,12,11,'d');box(26,10,42,11,'d')
  for x in range(2,49,5):
   box(x,11,x+1,11,'s');box(x+1,13,x+1,14,'s')
  box(15,5,22,16,'d');box(17,3,20,4,'d');box(18,1,19,2,'d');dot(18,0,'s')
  box(16,7,21,9,'s');box(17,7,20,8,'d');dot(19,8,'c')
  box(17,11,18,15,'s');box(20,11,20,15,'s')
  box(51,13,75,16,'l');box(57,10,67,12,'l');box(61,8,63,9,'l')
 elif kind=='TOWER BRIDGE':
  # Twin neo-Gothic towers connected by suspended arches above the Thames.
  box(4,14,76,16,'l');box(8,12,72,13,'d')
  for x in (14,59):
   box(x,5,x+7,14,'d');box(x+1,3,x+6,4,'d');box(x+2,1,x+5,2,'d')
   box(x+3,0,x+4,0,'s');box(x+2,7,x+3,8,'s');box(x+5,7,x+5,8,'s')
  box(23,10,58,11,'d');box(23,9,58,9,'s')
  for x in range(24,59,4):
   y=7+abs(x-41)//8
   box(x,y,x,9,'s')
  for x in range(0,80,8):box(x,16,x+3,16,'s')
 elif kind=='COVENT GARDEN':
  # Quiet Georgian arcade: pediment, columns and window arches.
  box(1,13,78,16,'d');box(5,5,74,6,'s');box(5,7,74,8,'d')
  box(10,3,69,4,'d');box(35,1,44,2,'d');box(37,0,42,0,'s')
  for x in (9,25,41,57,73):box(x,9,x+1,15,'s')
  for x in (14,30,46,62):
   box(x,10,x+6,14,'l');box(x+1,9,x+5,9,'s');box(x+2,11,x+4,14,'d')
  box(12,2,16,3,'l');box(62,2,67,3,'l')
 else:raise ValueError(kind)
 return [''.join(row) for row in g]

MAPS=['WESTMINSTER','TOWER BRIDGE','COVENT GARDEN']
CROPS=[9,14,24]
COLORS=[{'sky':'0x171720','ground':'0x302B39','d':'0x51485F','s':'0x80738B','l':'0x363847','c':'0xD8B984','menu':'0xE8E2EB'},
        {'sky':'0x15242B','ground':'0x293D44','d':'0x4B6973','s':'0x829DA4','l':'0x2A4A55','c':'0xD8B984','menu':'0xE0ECEF'},
        {'sky':'0x251E28','ground':'0x403139','d':'0x66535F','s':'0x9D818B','l':'0x503C49','c':'0xD8B984','menu':'0xF0E8E4'}]

def render():
 out=Path(__file__).resolve().parents[1]/'shots';out.mkdir(exist_ok=True)
 sheet=Image.new('RGB',(3*320,150),(235,232,226));d=ImageDraw.Draw(sheet)
 for i,n in enumerate(MAPS):
  c=COLORS[i]; im=Image.new('RGB',(80,30),int(c['sky'][2:],16))
  for y,row in enumerate(scene(n)):
   for x,v in enumerate(row):
    if v!='.':im.putpixel((x,y+7),tuple(bytes.fromhex(c[v][2:])))
  d.rectangle((i*320,0,(i+1)*320-1,20),fill=tuple(bytes.fromhex(c['menu'][2:])))
  sheet.paste(im.resize((320,120),Image.Resampling.NEAREST),(i*320,20))
  d.text((i*320+7,4),n,fill=(39,38,53))
 sheet.save(out/'map_study.png')
if __name__=='__main__':render()

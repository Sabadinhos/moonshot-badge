"""Original 10x10 SOL coin for the badge (two shimmer frames)."""
from PIL import Image
from pathlib import Path

def coin(frame=0):
    p=[['.']*10 for _ in range(10)]
    for y in range(10):
        for x in range(10):
            r=(x-4.5)**2+(y-4.5)**2
            if r<=22:p[y][x]='y' if r>=13 else 'k'
    # Three skewed bands give the recognisable Solana mark inside a gold rim.
    for y,x0,x1,color in ((2,3,6,'e'),(4,2,7,'b'),(6,3,7,'e')):
        for x in range(x0,x1+1):
            if p[y][x]!='.':p[y][x]=color
    p[1][3 if frame==0 else 6]='w'
    p[8][6 if frame==0 else 3]='w'
    return [''.join(row) for row in p]

if __name__=='__main__':
    colors={'.':(25,23,34),'y':(218,190,134),'k':(39,35,55),'e':(49,207,167),'b':(155,106,234),'w':(255,249,218)}
    im=Image.new('RGB',(100,50),colors['.'])
    for f in range(2):
        for y,row in enumerate(coin(f)):
            for x,c in enumerate(row):
                if c!='.':
                    for yy in range(5):
                        for xx in range(5):im.putpixel((f*50+x*5+xx,y*5+yy),colors[c])
    dst=Path(__file__).resolve().parents[1]/'shots'/'sol_coin_study.png'
    im.save(dst);print(dst)

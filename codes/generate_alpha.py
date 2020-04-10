import glob
from PIL import Image, ImageFilter, ImageEnhance
import os
from itertools import chain

search_dir = "Source"
ext_list = ["PNG", "png"]
paths = list(chain.from_iterable([glob.glob(os.path.join(search_dir, "*." + ext)) for ext in ext_list]))

for path in paths:
    im = Image.open(path)
    if im.mode == 'RGBA':
        alpha = im.split()[-1]
        alpha = alpha.convert("RGB")
        dst = os.path.split(path)
        ext = os.path.splitext(dst[1])
        alpha.save("codes/temp/" + ext[0] + '_alpha' + ext[1])
        #print(dst[0] + '_alpha' + dst[1])
from PIL import Image, ImageFilter, ImageEnhance
import os
import glob

paths = glob.glob("codes/mmsr/results/*/IMG/*_alpha.*")

for path in paths:
    print("Processing " + path + ".")
    alpha = Image.open(path)
    # Grayscale
    alpha = alpha.convert("L")

    print("Alphamap: Gaussian Blur")
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))

    print("Merging Colormap with Alphamap.")
    im = Image.open(path.replace('_alpha.', '.'))
    im.putalpha(alpha.split()[-1])
    im.save(path.replace('_alpha.', '.'))
    os.remove(path)
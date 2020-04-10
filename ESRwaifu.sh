#!/bin/sh
files=`find "Source" -type f \( -name \*.png -or -name \*.PNG -or -name \*.jpg -or -name \*.JPG -or -name \*.jpeg -or -name \*.LPEG -or -name \*.ppm -or -name \*.PPM -or -name \*.bmp -or -name \*.BMP \) `
if [ -z "$files" ]; then
  echo "No image files found in Source dir. Exit."
  exit 1
fi

while getopts m:n:h OPT
do
  case $OPT in
    m ) FLAG_M="TRUE"
        MODE=$OPTARG ;;
    n ) FLAG_N="TRUE"
        NOISE_LV=$OPTARG ;;
    h ) echo "Usage: sh $0 -m mode [-n]\nModes:\n\tx2\t\tESRGAN x2\n\tx4\t\tESRGAN x4\n\tresnetx2\tSRResNet x2\nOptions:\n\t-n [0-3]\tJPEG Noise Reduction Level[WIP]\n\t-h\t\tShow help" 1>&2
         exit 1 ;;
    : ) echo "Option $OPTARG requires an argument." 1>&2
        exit 1 ;;
    \? ) echo "Usage: sh $0 -m mode [-n]\nModes:\n\tx2\t\tESRGAN x2\n\tx4\t\tESRGAN x4\n\tresnetx2\tSRResNet x2\nOptions:\n\t-n [0-3]\tJPEG Noise Reduction Level[WIP]\n\t-h\t\tShow help" 1>&2
         exit 1 ;;
  esac
done
if [ ! $FLAG_M ]; then
    echo "The mode option is required."
    echo "Usage: sh $0 -m mode [-n]\nModes:\n\tx2\t\tESRGAN x2\n\tx4\t\tESRGAN x4\n\tresnetx2\tSRResNet x2\nOptions:\n\t-n [0-3]\tJPEG Noise Reduction Level[WIP]\n\t-h\t\tShow help" 1>&2
    exit 1
fi
# echo "Choose Scale:\n  1: x2\n  2: x4"
# read input

case $MODE in
    "x2" ) cmd="python test.py -opt ../../ESRGANx2_Pix2D.yml"
          cp codes/RRDBNet_arch_x2.py codes/mmsr/codes/models/archs/RRDBNet_arch.py ;;
    "x4" ) cmd="python test.py -opt ../../ESRGANx4_Pix2D.yml"
          cp codes/RRDBNet_arch_x4.py codes/mmsr/codes/models/archs/RRDBNet_arch.py ;;
    "resnetx2" ) cmd="python test.py -opt ../../SRResNetx2_Pix2D.yml" ;;
    * ) echo Invalid mode. Exit.
        exit 1
esac

echo "Preparing images..."
mkdir -p codes/temp

if [ $FLAG_N ]; then
    # WIP
    # echo "Reducing JPEG noise..."
    # cd codes/waifu2x
    # for file in $files;
    # do
    #     base=`basename $file .e`
    #     th waifu2x.lua -m noise_scale -noise_level $NOISE_LV -i ../../$file -o ../temp/$base
    # done
    # cd ../../
else
    for file in $files;
    do
        cp $file "codes/temp/"
    done
fi

echo "Upscale images..."
cd codes/mmsr/codes
eval ${cmd} | grep Processing
cd ../../../
rm codes/temp/*

echo "Generate alphamap..."
python codes/generate_alpha.py

if [ -f codes/temp/* ]; then
    echo "Upscale alphamap..."
    cd codes/mmsr/codes
    eval ${cmd} | grep Processing
    cd ../../../
fi

if [ -f codes/mmsr/results/*/IMG/*_alpha.* ]; then
    echo "Merge alphamap..."
    python codes/merge_alpha.py
fi

echo "Cleaning temporary files..."
mkdir -p Result/${MODE}
mv codes/mmsr/results/*/IMG/* Result/${MODE}
rm -rf codes/mmsr/results
rm -rf codes/temp

echo "Done."
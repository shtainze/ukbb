#!bin/sh -u
set -e

#####################
# Download & process UKBB data
#		which are not frequently used
#####################


source code/load_directory_tree.sh


#####################
# Download
#####################

echo ""
echo $(date) "Start downloading UKBB miscellaneous data"
echo "Output folder:" "$DIR_DATA_UKBB_4020457"

cd "$DIR_DATA_UKBB_4020457"

echo ""
echo $(date) "Download:"

# Haplotypes BGEN
echo "Haplotypes BGEN"
"$DIR_SOFTWARE_UKBB"gfetch \
22438 -c1 -m \
-ak62001r671006.key &

# Relatedness
echo "Relatedness"
"$DIR_SOFTWARE_UKBB"gfetch \
rel \
-ak62001r671006.key &

# Intensity
echo "Intensity"
"$DIR_SOFTWARE_UKBB"gfetch \
22430 -c1 \
-ak62001r671006.key &

# Confidences
echo "Confidences"
"$DIR_SOFTWARE_UKBB"gfetch \
22419 -c1 \
-ak62001r671006.key &

# CNV log2r
echo "CNV log2r"
"$DIR_SOFTWARE_UKBB"gfetch \
22431 -c1 \
-ak62001r671006.key &

# CNV baf
echo "CNV baf"
"$DIR_SOFTWARE_UKBB"gfetch \
22437 -c1 \
-ak62001r671006.key &


#mv ./ukb22438_c1_b0_v2.bgen "$DIR_DATA_UKBB_GENOTYPE_RAW"


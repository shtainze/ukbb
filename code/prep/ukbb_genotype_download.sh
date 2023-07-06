#!bin/sh -u
set -e

#####################
# Download & process UKBB genotype data (bulk)
#####################

DIR_OUT=$1
DIR_DATA_UKBB_GENOTYPE_RAW=$2
DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN=$3

#####################
# Download
# Due to the architecture of `gfetch`,
#		the files are first downloaded to "$DIR_OUT"
#	  (because it has a shorter path)
#		and then moved to respective storage directories
#####################

echo ""
echo $(date) "Start downloading UKBB genotype data"

cd "$DIR_OUT"
echo "Temporary download directory:" "$DIR_OUT"
FILE_KEY=$(find ./ -name "*.key")
echo "Using key:" "$FILE_KEY"


# FAM file (chromosome number is required but does not matter)
echo ""
echo $(date) "Download .fam file..."
rm -f ./*.fam
gfetch 22418 -c1 -m -a"$FILE_KEY"
FILE_DOWNLOADED=$(find ./ -name "*.fam" -maxdepth 1)
chmod 777 "$FILE_DOWNLOADED"
mv "$FILE_DOWNLOADED" "$DIR_DATA_UKBB_GENOTYPE_RAW"
echo $(date) "Downloaded to" "$DIR_DATA_UKBB_GENOTYPE_RAW"

# Genotype call
echo ""
echo $(date) "Download .bed file..."
gfetch 22418 -c1 -a"$FILE_KEY" &
# Imputation sample (chromosome number is required but does not matter)
# Available for autosomes, chrX and chrXY.
echo "Download imputation samples..."
gfetch 22828 -c1 -m -a"$FILE_KEY" &
gfetch 22828 -cX -m -a"$FILE_KEY" &
gfetch 22828 -cXY -m -a"$FILE_KEY" &
wait

FILE_DOWNLOADED=$(find ./ -name "*.bed" -maxdepth 1)
mv "$FILE_DOWNLOADED" "$DIR_DATA_UKBB_GENOTYPE_RAW"
mv ./ukb22828_*.sample "$DIR_DATA_UKBB_GENOTYPE_RAW"
echo $(date) "Downloaded to" "$DIR_DATA_UKBB_GENOTYPE_RAW"

# Imputation BGEN (the largest files)
echo ""
echo $(date) "Download imputation BGEN (might take days)..."
echo $(date) "Chr 1-5"
gfetch 22828 -c1 -a"$FILE_KEY" &
gfetch 22828 -c2 -a"$FILE_KEY" &
gfetch 22828 -c3 -a"$FILE_KEY" &
gfetch 22828 -c4 -a"$FILE_KEY" &
gfetch 22828 -c5 -a"$FILE_KEY" &
wait

echo ""
echo $(date) "Chr 6-10"
gfetch 22828 -c6 -a"$FILE_KEY" &
gfetch 22828 -c7 -a"$FILE_KEY" &
gfetch 22828 -c8 -a"$FILE_KEY" &
gfetch 22828 -c9 -a"$FILE_KEY" &
gfetch 22828 -c10 -a"$FILE_KEY" &
wait

echo ""
echo $(date) "Chr 11-15"
gfetch 22828 -c11 -a"$FILE_KEY" &
gfetch 22828 -c12 -a"$FILE_KEY" &
gfetch 22828 -c13 -a"$FILE_KEY" &
gfetch 22828 -c14 -a"$FILE_KEY" &
gfetch 22828 -c15 -a"$FILE_KEY" &
wait

echo ""
echo $(date) "Chr 16-20"
gfetch 22828 -c16 -a"$FILE_KEY" &
gfetch 22828 -c17 -a"$FILE_KEY" &
gfetch 22828 -c18 -a"$FILE_KEY" &
gfetch 22828 -c19 -a"$FILE_KEY" &
gfetch 22828 -c20 -a"$FILE_KEY" &
wait

echo ""
echo $(date) "Chr 21,22,X,XY"
gfetch 22828 -c21 -a"$FILE_KEY" &
gfetch 22828 -c22 -a"$FILE_KEY" &
gfetch 22828 -cX -a"$FILE_KEY" &
gfetch 22828 -cXY -a"$FILE_KEY" &
wait

mv ./ukb22828_*.bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"
echo $(date) "Downloaded to" "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"

echo ""
echo $(date) "Done."
echo ""
#!bin/sh -u
set -e

#####################
# Download & process UKBB genotype data (bulk)
#####################

source code/load_directory_tree_202307.sh

DIR_OUT="$DIR_DATA_UKBB_LATEST"


#####################
# Download
#####################

# bash "$DIR_CODE_PREP""ukbb_genotype_download.sh" \
# "$DIR_OUT" \
# "$DIR_DATA_UKBB_GENOTYPE_RAW" \
# "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN" \
# "$DIR_DATA_ACCEL_UKBB_WHITE"


#####################
# Convert from .bgen to .pgen
# Merge them all without filtering
#####################

# bash "$DIR_CODE_PREP""ukbb_genotype_merge_all.sh" \
# "$DIR_DATA_UKBB_GENOTYPE_RAW" \
# "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN" \
# "$DIR_DATA_UKBB_GENOTYPE_PGEN" \
# "$DIR_DATA_ACCEL_UKBB_WHITE"

# # Postprocessing
# bash "$DIR_CODE_PREP""ukbb_genotype_postprocessing.sh" \
# "$DIR_DATA_UKBB_GENOTYPE_PGEN" \
# "merged"


#####################
# Extract White British
#####################

echo ""
echo $(date) "Extract White British"
echo ""

plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""merged" \
--keep "$DIR_DATA_ACCEL_UKBB_WHITE""id.txt" \
--out "$DIR_DATA_UKBB_GENOTYPE_WHITE_ALL""merged"

# Postprocessing
bash "$DIR_CODE_PREP""ukbb_genotype_postprocessing.sh" \
"$DIR_DATA_UKBB_GENOTYPE_WHITE_ALL" \
"merged"


#####################
# Extract PanUKBB-listed variants
#####################

echo ""
echo $(date) "Extract PanUKBB-listed variants"
echo ""

plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_WHITE_ALL""merged" \
--extract "$DIR_DATA_PANUKBB_MAGMA""snp_id_only.txt" \
--out "$DIR_DATA_UKBB_GENOTYPE_WHITE_PAN""merged"

# Postprocessing
bash "$DIR_CODE_PREP""ukbb_genotype_postprocessing.sh" \
"$DIR_DATA_UKBB_GENOTYPE_WHITE_PAN" \
"merged"


#####################
# Extract QC-filtered variants
#####################

echo ""
echo $(date) "Extract QC-filtered variants"
echo ""

plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_WHITE_ALL""merged" \
--geno --mind --maf --mach-r2-filter \
--out "$DIR_DATA_UKBB_GENOTYPE_WHITE_QC""merged"

# Postprocessing
bash "$DIR_CODE_PREP""ukbb_genotype_postprocessing.sh" \
"$DIR_DATA_UKBB_GENOTYPE_WHITE_QC" \
"merged"


#####################
# Extract population with ACCEL dataset
#####################

echo ""
echo $(date) "Extract population with ACCEL dataset"
echo ""

plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_WHITE_QC""merged" \
--geno --mind --maf --mach-r2-filter \
--out "$DIR_DATA_UKBB_GENOTYPE_WHITEACCEL_QC""merged"

# Postprocessing
bash "$DIR_CODE_PREP""ukbb_genotype_postprocessing.sh" \
"$DIR_DATA_UKBB_GENOTYPE_WHITEACCEL_QC" \
"merged"


echo ""
echo $(date) "Done."
echo ""
#!bin/sh -u
set -e


#####################
# Extract part of the
# Triple-CRISPR database ("$FILE_DATABASE")
# only for the specified genes ("$FILE_GENES")
#####################


source code/load_directory_tree.sh

# Input: genotype
PATH_GENO="$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british
# Input: covariates
FILE_COVAR="$DIR_DATA_ACCEL_UKBB_COVAR""covar_age_sex_combination_pc10.txt"
# Input: phenotype
FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PLINK""ukb671006_00893_1160-0.0.txt"
# Input: allele frequency
FILE_FREQ="$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.freq.afreq"

# Output folder
DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230426_03_gwas_sleepduration/"
PATH_OUT="$DIR_OUT""out"
mkdir -p "$DIR_OUT"


#####################


echo ""
echo $(date) "Start GWAS using PLINK2"
echo ""

plink2 \
--pfile "$PATH_GENO" \
--glm \
--covar "$FILE_COVAR" \
--covar-variance-standardize \
--vif 999999 \
--adjust \
--read-freq "$FILE_FREQ" \
--pheno "$FILE_PHENO" \
--out "$PATH_OUT"

echo ""
echo $(date) "Done."
echo ""

#!bin/sh -u
set -e


#####################
# Try making PGS based on a GWAS result
#####################


source code/load_directory_tree_202307.sh

# Input: PLINK2-related
# Input: phenotype
FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PROCESSED""1180-0.0/accel_only/1234_plink.txt"
# Input: genotype
PATH_GENO="$DIR_DATA_UKBB_GENOTYPE_WHITEACCEL_QC""merged"
# Input: allele frequency
FILE_FREQ="$PATH_GENO"".freq.afreq"
# Input: GWAS result
FILE_GWAS_RESULT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230705_01_gwas/accel_only/out.1180-0.0.glm.linear"

# Output
DIR_OUT_ROOT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230726_01_pgs_test/"
DIR_OUT_1="$DIR_OUT_ROOT""default/"
DIR_OUT_2="$DIR_OUT_ROOT""variance_standardize/"
mkdir -p "$DIR_OUT_ROOT"
mkdir -p "$DIR_OUT_1"
mkdir -p "$DIR_OUT_2"

# Intermedite output: GWAS result, truncated as --score input
FILE_GWAS_RESULT_TRUNCATED="$DIR_OUT_ROOT""gwas_result_truncated.txt"
PATH_OUT_1="$DIR_OUT_1""out"
PATH_OUT_2="$DIR_OUT_2""out"

# Output
# PGS
FILE_OUT_1_SCORE="$PATH_OUT_1"".sscore"
FILE_OUT_2_SCORE="$PATH_OUT_2"".sscore"
# PGS, sorted
FILE_OUT_1_SCORE_SORTED="$PATH_OUT_1"".sscore.sorted.txt"
FILE_OUT_2_SCORE_SORTED="$PATH_OUT_2"".sscore.sorted.txt"
# Phenotype + PGS
FILE_OUT_1_PHENO_PGS="$DIR_OUT_1""pheno_PGS.txt"
FILE_OUT_2_PHENO_PGS="$DIR_OUT_2""pheno_PGS.txt"


#####################
# Truncate GWAS result as --score input
#####################

echo ""
echo $(date) "Truncate GWAS result as --score input"
echo "Input:" "$FILE_GWAS_RESULT"
echo "Output:" "$FILE_GWAS_RESULT_TRUNCATED"
cat "$FILE_GWAS_RESULT" | head -n 1 | awk -F'\t' -v OFS='\t' '{print $3,$6,$9}' > "$FILE_GWAS_RESULT_TRUNCATED"
cat "$FILE_GWAS_RESULT" | awk -F'\t' -v OFS='\t' '{if($7 == "ADD") {print $3,$6,$9}}' >> "$FILE_GWAS_RESULT_TRUNCATED"


#####################
# GWAS using PLINK2
#####################

echo ""
echo $(date) "Start making PGS using:"
echo "Genotype file =" "$PATH_GENO"
echo "GWAS result =" "$FILE_GWAS_RESULT"
echo ""

plink2 \
--pfile "$PATH_GENO" \
--read-freq "$FILE_FREQ" \
--score "$FILE_GWAS_RESULT_TRUNCATED" \
--threads 16 \
--out "$PATH_OUT_1"

echo ""

plink2 \
--pfile "$PATH_GENO" \
--read-freq "$FILE_FREQ" \
--score "$FILE_GWAS_RESULT_TRUNCATED" variance-standardize \
--threads 16 \
--out "$PATH_OUT_2"


#####################
# Make the table of phenotype & PGS
#####################


echo ""
echo $(date) "Sort & Join to make phenotype-PGS table"
echo "Input (Phenotype):" "$FILE_PHENO"

echo ""
echo "Input (PGS):" "$FILE_OUT_1_SCORE"
echo "Intermediate output:" "$FILE_OUT_1_SCORE_SORTED"
echo "Output:" "$FILE_OUT_1_PHENO_PGS"
cat "$FILE_OUT_1_SCORE" | head -n 1 > "$FILE_OUT_1_SCORE_SORTED"
cat "$FILE_OUT_1_SCORE" | tail -n +2 | sort -k1,1 >> "$FILE_OUT_1_SCORE_SORTED"
join "$FILE_PHENO" "$FILE_OUT_1_SCORE_SORTED" --header > "$FILE_OUT_1_PHENO_PGS"

echo ""
echo "Input (PGS):" "$FILE_OUT_2_SCORE"
echo "Intermediate output:" "$FILE_OUT_2_SCORE_SORTED"
echo "Output:" "$FILE_OUT_1_PHENO_PGS"
cat "$FILE_OUT_2_SCORE" | head -n 1 > "$FILE_OUT_2_SCORE_SORTED"
cat "$FILE_OUT_2_SCORE" | tail -n +2 | sort -k1,1 >> "$FILE_OUT_2_SCORE_SORTED"
join "$FILE_PHENO" "$FILE_OUT_2_SCORE_SORTED" --header > "$FILE_OUT_2_PHENO_PGS"



echo ""
echo "Done."
echo ""
#!bin/sh -u
set -e


#####################
# Format per-phenotype file for R input
#####################


source code/load_directory_tree.sh

DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230605_01_gwas/1180-0.0_Chronotype_fourway_small/"

# Intermediate output: SNP info extracted from PLINK2 output
FILE_FOR_MANHATTAN="$DIR_OUT""for_manhattan.txt"
FILE_FOR_MANHATTAN_CHR1="$DIR_OUT""for_manhattan_chr1.txt"
FILE_FOR_MANHATTAN_CHR11="$DIR_OUT""for_manhattan_chr11.txt"

# ####################
# # Format per-phenotype file for R input
# ####################

# echo ""
# echo $(date) "Format the per-phenotype file for R input"
# FILE_PVAL=$(find "$DIR_OUT" -name "*.adjusted")

# echo "Input:" "$FILE_PVAL"
# echo "Output:" "$FILE_FOR_MANHATTAN"

# # Extract "CHR", "BP", "SNP", "P"

# HEADER="CHR BP SNP P"
# echo "$HEADER" > "$FILE_FOR_MANHATTAN"

# cat "$FILE_PVAL" | tail -n +2 | awk -F'\t' '{
#     bp=$2
#     gsub(".*:", "", bp)
#     gsub(/\[.*/, "", bp)
#     print $1,bp,$2,$4
# }' >> "$FILE_FOR_MANHATTAN"


# #####################
# # Take out chr 1
# #####################

# echo $(date) "Extract chr1"
# echo "Input:" "$FILE_FOR_MANHATTAN"
# echo "Output:" "$FILE_FOR_MANHATTAN_CHR1"

# HEADER="CHR BP SNP P"
# echo "$HEADER" > "$FILE_FOR_MANHATTAN_CHR1"
# cat "$FILE_FOR_MANHATTAN" | tail -n +2 | awk '{if($1 == 1) print $0}' >> "$FILE_FOR_MANHATTAN_CHR1"


echo $(date) "Extract chr11"
echo "Input:" "$FILE_FOR_MANHATTAN"
echo "Output:" "$FILE_FOR_MANHATTAN_CHR11"

HEADER="CHR BP SNP P"
echo "$HEADER" > "$FILE_FOR_MANHATTAN_CHR11"
cat "$FILE_FOR_MANHATTAN" | tail -n +2 | awk '{if($1 == 11) print $0}' >> "$FILE_FOR_MANHATTAN_CHR11"



echo ""
echo $(date) "Done."
echo ""
#!bin/sh -u
set -e


#####################
# Extract part of the
# Triple-CRISPR database ("$FILE_DATABASE")
# only for the specified genes ("$FILE_GENES")
#####################


source code/load_directory_tree.sh

# Input: database
FILE_SOURCE="$DIR_CRISPR""Mus_musculus_20230209.csv"

# Output folder
DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230426_01_triple_crispr_panukbb_top25/2/"

# Input: gene list
FILE_GENES="$DIR_OUT""genes.txt"

# Output: database excerpt
FILE_OUT="$DIR_OUT""out.csv"
# Output: successfully extracted genes
FILE_OUT_INCLUDED_GENES="$DIR_OUT""out_included_genes.csv"
# Output: genes with no corresponding entries
FILE_OUT_EXCLUDED_GENES="$DIR_OUT""out_excluded_genes.csv"

echo ""
echo $(date) "Start processing..."
echo ""

HEADER=$(head -n 1 "$FILE_SOURCE")
HEADER=$(echo "$HEADER" | sed 's/\r//g' | sed 's/\n//g')
echo "$HEADER" > "$FILE_OUT"

sort "$FILE_GENES" | uniq | while read GENE
do
  GENE=$(echo "$GENE" | sed 's/\r//g' | sed 's/\n//g')
  echo $(date) $GENE
  cat "$FILE_SOURCE" | awk -F, -v OFS="," -v GENE=$GENE '{if($2==GENE) {print $0}}' >> "$FILE_OUT"
done

cat "$FILE_OUT" | tail -n +2 | awk -F, '{print $2}' | uniq > "$FILE_OUT_INCLUDED_GENES"

diff -b "$FILE_GENES" "$FILE_OUT_INCLUDED_GENES" > "$FILE_OUT_EXCLUDED_GENES"

echo ""
echo $(date) "Done."
echo ""
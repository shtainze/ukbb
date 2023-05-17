#!bin/sh -u
set -e

#####################
# Add full gene names to a list of abbreviated gene names
#####################


source code/load_directory_tree.sh


# Input - a list of abbreviated gene names
FILE_SOURCE="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230414_01_sleep_genebasedP/gene_pheno_pval_list.csv"
# List of gene names, abbreviation & full
FILE_ANNOT="$DIR_REFSEQ""gene_full_name_tab.txt"
# Output folder - change each time!
DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230414_01_sleep_genebasedP/"
# Temporary files
FILE_SOURCE_FORMATTED="$DIR_OUT""temp.txt"
# Final output
FILE_OUT="$DIR_OUT""gene_pheno_pval_list_annotated.csv"


mkdir -p "$DIR_OUT"

echo ""
echo $(date) "Add full gene names"
echo "Using annotation in:" "$FILE_ANNOT"
echo "To the data:" "$FILE_SOURCE"
echo "Output:" "$FILE_OUT"
echo ""
echo "Sort..."

# Format the files
#	Delimiters to Tab
#	Sort
cat "$FILE_SOURCE" | head -n 1 | sed "s/,/\t/g" | sed "s/ /_/g" > "$FILE_SOURCE_FORMATTED"
cat "$FILE_SOURCE" | tail -n +2 | sed "s/,/\t/g" | sed "s/ /_/g" | sort -k1,1 >> "$FILE_SOURCE_FORMATTED"

# Join
# Outer join (-a 1) to keep all the entries in the first file
echo ""
echo $(date) "Join..."
join --header -a 1 "$FILE_SOURCE_FORMATTED" "$FILE_ANNOT" | sed 's/ /,/g' > "$FILE_OUT"

echo ""
echo $(date) "Done."
echo ""
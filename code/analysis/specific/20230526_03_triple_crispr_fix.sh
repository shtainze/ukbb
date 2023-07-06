#!bin/sh -u
set -e


#####################
# Extract gene names from the
#   Triple-CRISPR database ("$FILE_DATABASE")
#   and extract conflicting gene names
#####################


source code/load_directory_tree.sh

# Input: database
FILE_SOURCE="$DIR_CRISPR""Mus_musculus_20230209.csv"

# Intermediate output: gene name list
FILE_GENE_NAME="$DIR_CRISPR""gene_name_only.txt"

# Output: Conflicting gene names
FILE_OUT="$DIR_CRISPR""gene_name_conflict.txt"


func_print() {
    i=$1
    if [ "$i" -lt 10 ] || [ "$(echo $i | sed 's/.\(0*\)$//')" = "" ]; then
        echo $(date) ":" "$i"
    fi
}


# Load the content of FILE_GENE_NAME into the variable CONTENT
GENES=$(cat "$FILE_GENE_NAME")

N_GENES_TOTAL=$(echo "$GENES" | wc -l | awk '{print $0}')
echo $(date) "Start processing" "$N_GENES_TOTAL" "genes"

echo "GENE MATCHES" > "$FILE_OUT"

I_GENE=1

# Process each line in CONTENT
echo "$GENES" | while IFS= read -r GENE
do
  func_print "$I_GENE"
  GENES_PARTIAL=$(echo "$GENES" | awk -v GENE=$GENE '{if($0 ~ GENE) print $0}')
  N_GENES_PARTIAL=$(echo $GENES_PARTIAL | awk '{print NF}')
  if [ $N_GENES_PARTIAL -gt 1 ]; then
    echo "$GENE" "$N_GENES_PARTIAL" >> "$FILE_OUT"
  fi
  I_GENE=$((I_GENE+1))
done

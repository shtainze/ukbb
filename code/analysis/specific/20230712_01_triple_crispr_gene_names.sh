#!bin/sh -u
set -e


#####################
# Extract gene names from the
#   Triple-CRISPR database ("$FILE_DATABASE")
#####################


source code/load_directory_tree_202307.sh

# Input/Output
DIR_OUT="$DIR_CRISPR""Mus_musculus_20230209_split/"
FILE_OUT="$DIR_OUT""genes_in_each_file.txt"

echo "Output:" "$FILE_OUT"
echo "File,Gene" > "$FILE_OUT"

for FILE_SOURCE in $(find "$DIR_OUT" -name "split_*.csv" | sort); do  
  FILENAME=$(echo "$FILE_SOURCE" | sed "s/.*\///g")
  echo "$FILE_SOURCE" "$FILENAME"
  # Extract gene names ($2)
  # And add origin file name (FILENAME)
  cat "$FILE_SOURCE" | tail -n +2 | awk -F',' -v OFS="," -v PREFIX="$FILENAME" '{print PREFIX,$2}' | uniq >> "$FILE_OUT"
done

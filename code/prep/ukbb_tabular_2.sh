#!bin/sh -u
set -e

#####################
# Preprocess UKBB tabular data.
# Fill empty fields with the string "NA" to prevent errors.
#####################

source code/load_directory_tree.sh

echo ""
echo $(date)
echo "Fill empty fields with the string NA to prevent errors..."
echo "Scanning inside the directory" "$DIR_DATA_UKBB_TABULAR_PROCESSED"


#####################
# check if any field in any row is exactly the same as "NA"
#####################

echo "Check if any field in any file is already "NA"..."
echo "If everything is alright, only the file names are displayed"

for FILE in $(find "$DIR_DATA_UKBB_TABULAR_PROCESSED" -type f -name "formatted*tsv" | sort); do
echo $(date): "Scanning" $FILE
cat "$FILE" | awk -F"\t" '{for (i=1; i<=NF; i++) if ($i == "NA") {print "Found NA in field " i " in row " NR; exit}}'
cat "$FILE" | awk -F"\t" '{for (i=1; i<=NF; i++) if ($i == "NAN") {print "Found NA in field " i " in row " NR; exit}}'
cat "$FILE" | awk -F"\t" '{for (i=1; i<=NF; i++) if ($i == "Nan") {print "Found NA in field " i " in row " NR; exit}}'
cat "$FILE" | awk -F"\t" '{for (i=1; i<=NF; i++) if ($i == "NaN") {print "Found NA in field " i " in row " NR; exit}}'
done


#####################
# Replace the empty fields with "NA"
#####################

FILE_HEADER=$(find "$DIR_DATA_UKBB_TABULAR_PROCESSED" -type f -name "formatted_0001.tsv")
FILE_MERGED="$DIR_DATA_UKBB_TABULAR_PROCESSED"merged.txt

echo ""
echo $(date)
echo "Formatting the new UKBB basket data..."
echo "Writing to" "$FILE_MERGED"

# Output the header row
HEADER=$(cat "$FILE_HEADER" | head -n 1 | sed 's/\n//g' | sed 's/\r//g')
echo "$HEADER" > "$FILE_MERGED"

# Replace & output
for FILE_SOURCE in $(find "$DIR_DATA_UKBB_TABULAR_PROCESSED" -type f -name "formatted*tsv" | sort); do
	echo $(date) "Processing" "$FILE_SOURCE"
    cat "$FILE_SOURCE" | tail -n +2 | sed 's/\t\t/\tNA\t/g' | sed 's/\t\t/\tNA\t/g' | sed 's/\t$/\tNA/g' >> "$FILE_MERGED"
done


# Make sure that no empty field remains
echo ""
echo $(date)
echo "Count the number of empty fields..."
echo "Output is only shown when there is any empty field"
cat "$FILE_MERGED" | \
awk -F"\t" '{
	for (i=1; i<=NF; i++) 
	if ($i == "") {print "Found NA in field " i " in row " NR; exit}
}'

echo ""
echo $(date)
echo "Done."
echo ""
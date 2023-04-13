#!bin/sh -u
set -e

#####################
# Extract the ID list of
# White British population
#####################


source code/load_directory_tree.sh


echo ""
echo $(date)
echo "Extract the ID list of White British population"


# Intermediate output
# Join relevant fields
FILE_TEMP="$DIR_DATA_ACCEL_UKBB_WHITE"joined_temp.txt
FILE_JOINED="$DIR_DATA_ACCEL_UKBB_WHITE"joined.txt
# Filtered for White British
FILE_FILTERED="$DIR_DATA_ACCEL_UKBB_WHITE"filtered.txt

# Final output - ids only
FILE_OUT="$DIR_DATA_ACCEL_UKBB_WHITE"id.txt


#####################
# Join relevant fields into one file
#####################

echo ""
echo $(date)
echo "Join relevant fields into one file..."
echo "Output:" "$FILE_JOINED"


# 21000-: Ethnic background
FILE_1=$(find "$DIR_DATA_ACCEL_UKBB_SPLIT" -type f | grep -e ".*21000-0.0.*" -)
FILE_2=$(find "$DIR_DATA_ACCEL_UKBB_SPLIT" -type f | grep -e ".*21000-1.0.*" -)
FILE_3=$(find "$DIR_DATA_ACCEL_UKBB_SPLIT" -type f | grep -e ".*21000-2.0.*" -)

# 22006-0.0: Genetic ethnic grouping
FILE_4=$(find "$DIR_DATA_ACCEL_UKBB_SPLIT" -type f | grep -e ".*22006-0.0.*" -)


join "$FILE_1" "$FILE_2" > "$FILE_TEMP"
mv "$FILE_TEMP" "$FILE_JOINED"
join "$FILE_JOINED" "$FILE_3" > "$FILE_TEMP" 
mv "$FILE_TEMP" "$FILE_JOINED"
join "$FILE_JOINED" "$FILE_4" > "$FILE_TEMP" 
mv "$FILE_TEMP" "$FILE_JOINED"


#####################
# Filter
#####################

echo ""
echo $(date)
echo "Filter..."
echo "Output:" "$FILE_OUT"
# 1001: White British
# 1: Genetic ethnic grouping = European
cat "$FILE_JOINED" | awk -F' ' '{if ($2=="1001" && $3=="NA" && $4=="NA" && $5=="1"){print $0}}' > "$FILE_FILTERED"
cat "$FILE_FILTERED" | awk -F' ' '{print $1, $1}' > "$FILE_OUT"


echo ""
echo $(date)
echo "Done."
echo ""
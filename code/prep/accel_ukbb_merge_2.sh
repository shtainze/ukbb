#!bin/sh -u
set -e

#####################
# This script merges the two datasets:
# 	1. UKBB ("$FILE_UKBB")
#	  2. ACCEL dataset ("$FILE_ACCEL")
#
# Since the eids (corresponding to the participants) are
#   different in 1. and 2., a matching will be performed
#   based on a lookup table. ("$FILE_LOOKUP_TABLE")
#####################


source code/load_directory_tree_202307.sh

# Input
FILE_UKBB="$DIR_DATA_UKBB_TABULAR_PROCESSED"merged.txt
FILE_ACCEL="$DIR_DATA_ACCEL"formatted.txt
# Lookup table sorted by the old eids
FILE_LOOKUP_TABLE_SORTED_OLD="$DIR_DATA_ACCEL"pair_ids_sorted_old.csv
# Lookup table sorted by the new eids
FILE_LOOKUP_TABLE_SORTED_NEW="$DIR_DATA_ACCEL"pair_ids_sorted_new.csv

# Join the lookup table
# And put "eid" column to the 1st place
FILE_ACCEL_ID_MATCHED="$DIR_DATA_ACCEL_UKBB_MERGING"id_matched.txt
FILE_ACCEL_ID_MATCHED_FORMATTED="$DIR_DATA_ACCEL_UKBB_MERGING"id_matched_formatted.txt

# Final output
# Merged file
FILE_OUT="$DIR_DATA_ACCEL_UKBB"ukbb_accel_merged.txt
# Merged and formatted
FILE_OUT_2="$DIR_DATA_ACCEL_UKBB"ukbb_accel_merged_formatted.txt
# Extraction of individuals with ACCEL entries
FILE_OUT_3="$DIR_DATA_ACCEL_UKBB"ukbb_accel_accel_only.txt

echo ""
echo $(date) "Merge ACCEL data and the new UKBB basket"

##########################


# Join the lookup table
# And put "eid" column to the 1st place
echo ""
echo $(date) "Join the ACCEL data and the lookup table..."
echo "Output:" "$FILE_ACCEL_ID_MATCHED"

join --header -t, "$FILE_ACCEL" "$FILE_LOOKUP_TABLE_SORTED_OLD" | awk -F "," -v OFS="," '
{
  # Save the 36th column to a temporary variable
  temp = $36;
  
  # Loop over columns 2 to 36
  for (i = 36; i > 1; i--) {
    # Shift each column one step to the right
    $i = $(i-1);
  }
  
  # Set the 1st column to be the value from the temporary variable
  $1 = temp;
  
  # Print the line
  print;
}' > "$FILE_ACCEL_ID_MATCHED"

# Sort by the first column (id)
# Change the delimiter from comma to tab
# Fill empty fields with "NA"
echo ""
echo $(date) "Sort & format..."
echo "Output:" "$FILE_ACCEL_ID_MATCHED_FORMATTED"

(head -n +1 "$FILE_ACCEL_ID_MATCHED" && tail -n +2 "$FILE_ACCEL_ID_MATCHED" | sort -t',' -k1,1) | sed 's/\r//g' | sed 's/,/\t/g' | sed 's/\t\t/\tNA\t/g' | sed 's/\t\t/\tNA\t/g' | sed 's/\t$/\tNA/g' > "$FILE_ACCEL_ID_MATCHED_FORMATTED"

##########################

echo ""
echo $(date) "Verify file sanity..."

# Check that all rows have the same number of columns
echo "ACCEL data:" "$FILE_ACCEL_ID_MATCHED_FORMATTED"
TEMP=$(cat "$FILE_ACCEL_ID_MATCHED_FORMATTED" | awk -F'\t' '{print NF}' | uniq | wc -l)
if [ "$TEMP" -ne 1 ]; then
  echo "Different number of columns exist depending on the rows."
else
  echo "All rows have the same number of columns."
fi

# Check that the original file is already sorted
cat "$FILE_ACCEL_ID_MATCHED_FORMATTED" | tail -n +2 | sort -t ',' -c -k 1
if [ $? -ne 0 ]; then
  echo "File is not sorted by the first column."
else
  echo "File is sorted by the first column."
fi


echo "New UKBB basket:" "$FILE_UKBB"
# Check that the file is already sorted
cat "$FILE_UKBB" | tail -n +2 | sort -t ',' -c -k 1
if [ $? -ne 0 ]; then
  echo "File is not sorted by the first column."
else
  echo "File is sorted by the first column."
fi

##########################

echo ""
echo $(date) "Join the ACCEL data and the new UKBB basket data"
echo "Input:" "$FILE_UKBB", "$FILE_ACCEL_ID_MATCHED_FORMATTED"
echo "Output:" "$FILE_OUT"
join --header -t $'\t' -a 1 "$FILE_UKBB" "$FILE_ACCEL_ID_MATCHED_FORMATTED" > "$FILE_OUT"

echo ""
echo $(date) "Fill NA for the entries not containing ACCEL data"
echo "Output:" "$FILE_OUT_2"

FIELD_NUM_ALL=$(cat "$FILE_OUT" | head -n 100 | \
  awk -F'\t' '{print NF}' | sort -n | tail -n 1)

FIELD_NUM_NOACCEL=$((FIELD_NUM_ALL - 35))

echo "$FIELD_NUM_ALL", "$FIELD_NUM_NOACCEL" "fields are found"

cat "$FILE_OUT" | awk -F'\t' -v OFS='\t' \
-v FIELD_NUM_ALL=$FIELD_NUM_ALL \
-v FIELD_NUM_NOACCEL=$FIELD_NUM_NOACCEL \
'{
  if (NF == FIELD_NUM_ALL) {
    print $0
  } else if (NF == FIELD_NUM_NOACCEL) {
    print $0"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
  }
}' | sed 's/\r//g' > "$FILE_OUT_2"


echo ""
echo $(date) "Extraction of individuals with ACCEL entries"

HEADER=$(head -n 1 "$FILE_OUT_2")
IFS=$'\t' read -ra COLUMNS <<< "$HEADER"

# Find column numbers for "eid_old"
for i in "${!COLUMNS[@]}"; do
  if [[ "${COLUMNS[i]}" == "eid_old" ]]; then
    COL_NUMBER=$((i + 1))
  fi
done

# Get the number of ACCEL entries
# STR_COMMAND="cat "$FILE_OUT_2" | awk -F'\t' '{print \$"$COL_NUMBER"}' | awk '{if (\$0 != \"NA\") print \$0}' | wc -l"
# echo "$STR_COMMAND"
# N_INDIV=$(eval "$STR_COMMAND")

echo "Column" "$COL_NUMBER" "contains ACCEL IDs. Extract the rows with non-NA entries in this column..."
echo "Output:" "$FILE_OUT_3"

STR_COMMAND="cat "$FILE_OUT_2" | awk -F'\t' -v OFS='\t' '{if (\$"$COL_NUMBER" != \"NA\") print \$0}' > "$FILE_OUT_3""
eval "$STR_COMMAND"


echo ""
echo $(date) "Done."
echo ""
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


source code/load_directory_tree.sh

# Input
FILE_UKBB="$DIR_DATA_UKBB_TABULAR_PROCESSED"merged.txt
FILE_LOOKUP_TABLE="$DIR_DATA_UKBB_TABULAR_PROCESSED"pair_ids.csv
FILE_ACCEL="$DIR_DATA_ACCEL"formatted.txt

# Intermediate output
# Lookup table sorted by the old eids
FILE_LOOKUP_TABLE_SORTED_OLD="$DIR_DATA_UKBB_TABULAR_PROCESSED"pair_ids_sorted_old.csv
# Lookup table sorted by the new eids
FILE_LOOKUP_TABLE_SORTED_NEW="$DIR_DATA_UKBB_TABULAR_PROCESSED"pair_ids_sorted_new.csv
# Join the lookup table
# And put "eid" column to the 1st place
FILE_ACCEL_ID_MATCHED="$DIR_DATA_ACCEL"id_matched.txt
FILE_ACCEL_ID_MATCHED_FORMATTED="$DIR_DATA_ACCEL"id_matched_formatted.txt

# Final output
FILE_OUT="$DIR_DATA_ACCEL_UKBB"ukbb671006_accel_merged.txt
FILE_OUT_2="$DIR_DATA_ACCEL_UKBB"ukbb671006_accel_merged_formatted.txt



##########################

echo ""
echo $(date)
echo "Sort the lookup table..."
(head -n +1 "$FILE_LOOKUP_TABLE" && tail -n +2 "$FILE_LOOKUP_TABLE" | sort -t',' -k1,1) | sed 's/\r//g' > "$FILE_LOOKUP_TABLE_SORTED_OLD"
(head -n +1 "$FILE_LOOKUP_TABLE" && tail -n +2 "$FILE_LOOKUP_TABLE" | sort -t',' -k2,2) | sed 's/\r//g' | awk -F, -v OFS="," '{print $2,$1}' > "$FILE_LOOKUP_TABLE_SORTED_NEW"

# Join the lookup table
# And put "eid" column to the 1st place
echo ""
echo $(date)
echo "Join the ACCEL data and the lookup table..."
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
echo $(date)
echo "Sort & format..."
(head -n +1 "$FILE_ACCEL_ID_MATCHED" && tail -n +2 "$FILE_ACCEL_ID_MATCHED" | sort -t',' -k1,1) | sed 's/\r//g' | sed 's/,/\t/g' | sed 's/\t\t/\tNA\t/g' | sed 's/\t\t/\tNA\t/g' | sed 's/\t$/\tNA/g' > "$FILE_ACCEL_ID_MATCHED_FORMATTED"

##########################

echo ""
echo $(date)
echo "Verify file sanity..."

# Check that all rows have the same number of columns
echo "ACCEL data:"
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


echo "UKBB new basket:"

# Check that the file is already sorted
cat "$FILE_UKBB" | tail -n +2 | sort -t ',' -c -k 1
if [ $? -ne 0 ]; then
  echo "File is not sorted by the first column."
else
  echo "File is sorted by the first column."
fi

##########################

echo ""
echo $(date)
echo "Join the ACCEL data and the new UKBB basket data..."
join --header -t $'\t' -a 1 "$FILE_UKBB" "$FILE_ACCEL_ID_MATCHED_FORMATTED" > "$FILE_OUT"

echo ""
echo $(date)
echo "Fill NA for the entries not containing ACCEL data..."
cat "$FILE_OUT" | awk -F'\t' -v OFS='\t' '{
  if (NF == 28483) {
    print $0
  } else if (NF == 28448) {
    print $0"\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA\tNA"
  }
}' | sed 's/\r//g' > "$FILE_OUT_2"

echo ""
echo $(date)
echo "Done."
echo ""
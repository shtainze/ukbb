source code/load_directory_tree.sh


#########################################
# Extract leftovers from the first-step join
#########################################

# Input: All data of the old dataset
FILE_DATA_OLD="$DIR_DATA_UKBB_34134""ukb34134.csv"
# Input: Non-paired ids of the old dataset
FILE_IDS_OLD_ONLY="$DIR_DATA_ACCEL_UKBB_MERGING""nonpaired_ids_old.csv"

# Input: All data of the new dataset
FILE_DATA_NEW="$DIR_DATA_UKBB_TABULAR_PROCESSED""merged.txt"
# Input: Non-paired ids of the new dataset
FILE_IDS_NEW_ONLY="$DIR_DATA_ACCEL_UKBB_MERGING""nonpaired_ids_new.csv"

# Intermediate output: quotation marks added
FILE_IDS_OLD_ONLY_QUOTE="$DIR_DATA_ACCEL_UKBB_MERGING""nonpaired_ids_old_quote.csv"

# Output: Non-paired fraction of the old dataset
FILE_DATA_OLD_ONLY="$DIR_DATA_ACCEL_UKBB_MERGING""nonpaired_data_old.csv"
# Output: Non-paired fraction of the new dataset
FILE_DATA_NEW_ONLY="$DIR_DATA_ACCEL_UKBB_MERGING""nonpaired_data_new.csv"


echo ""
echo $(date) "Extract leftovers from the first-step join"

# Intermediate output: quotation marks added
echo ""
echo $(date) "Add quotation marks to the old dataset"
echo "Input:" "$FILE_IDS_OLD_ONLY"
echo "Output:" "$FILE_IDS_OLD_ONLY_QUOTE"
cat "$FILE_IDS_OLD_ONLY" | sed 's/.*/"&"/' > "$FILE_IDS_OLD_ONLY_QUOTE"

# Use awk to extract leftover entries based on ID lists
echo ""
echo $(date) "Extract leftover entries based on ID lists"
echo $(date) "Input: old file - data:" "$FILE_DATA_OLD", "ID list:" "$FILE_IDS_OLD_ONLY_QUOTE"
echo "Output:" "$FILE_DATA_OLD_ONLY"
cat "$FILE_DATA_OLD" | head -n 1 > "$FILE_DATA_OLD_ONLY"
awk -F, 'NR==FNR{a[$1];next} $1 in a' "$FILE_IDS_OLD_ONLY_QUOTE" "$FILE_DATA_OLD" >> "$FILE_DATA_OLD_ONLY"

echo ""
echo $(date) "Input: new file - data:" "$FILE_DATA_NEW", "ID list:" "$FILE_IDS_NEW_ONLY"
echo "Output:" "$FILE_DATA_NEW_ONLY"
cat "$FILE_DATA_NEW" | head -n 1 > "$FILE_DATA_NEW_ONLY"
awk -F'\t' 'NR==FNR{a[$1];next} $1 in a' "$FILE_IDS_NEW_ONLY" "$FILE_DATA_NEW" >> "$FILE_DATA_NEW_ONLY"

echo ""
echo $(date) "Done."
echo ""

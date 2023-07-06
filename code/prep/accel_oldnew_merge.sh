#!bin/sh -u
set -e

#####################
# Merge the two versions of UKBiobank accelerometry datasets
# 	1. Katori et el. 2022 (based on basket 34134)
#	  2. Mr. Hiroyuki Sato (based on basket 46356, 52509)
# Both are essentially bunch of .cwa files acquired from the 
#   same set of individuals, but with different IDs (and file names)
#####################


source code/load_directory_tree_202307.sh

# Input: storage directory of old/new cwa files
DIR_CWA_OLD=""
DIR_CWA_NEW="/home/disk1/HiroyukiSATO/UKBiobank/cwa/"

# Output
DIR_OUT="$DIR_DATA_ACCEL_UKBB""cwa_merge/"
mkdir -p "$DIR_OUT"

# Output: list of files in old/new datasets
#   Format: file_name sha256_of_first_10k_characters
FILE_LIST_OLD="$DIR_OUT""file_list_old.txt"
FILE_LIST_NEW="$DIR_OUT""file_list_new.txt"
FILE_LIST_OLD_SORTED="$DIR_OUT""file_list_old_sorted.txt"
FILE_LIST_NEW_SORTED="$DIR_OUT""file_list_new_sorted.txt"
FILE_LIST_JOINED="$DIR_OUT""file_list_joined.txt"
# Output: ID pairs extracted
FILE_ID_PAIRS="$DIR_OUT""pair_ids.txt"

echo ""
echo $(date)
echo "Merge two ACCEL datasets"


##########################
# List up new dataset files
##########################

echo ""
echo $(date)
echo "List up new files..."

echo "file first_1000_chars" > "$FILE_LIST_NEW"

# Find all files in the directory and its subdirectories
find "$DIR_CWA_NEW" -type f -name "*.cwa" | while IFS= read -r file; do
    # Get the file name
    file_name=$(basename "$file")
    
    # # Read the first 1000 characters of the file
    # first_1000_chars=$(cat "$file" | head -c 1000000 | tail -c 1000) 
    # # Output the file name and the first 1000 characters to the output file
    # echo "$file_name" "$first_1000_chars" >> "$FILE_LIST_NEW"

    # Get sha256 sum of the first 10k letters
    sha256sum=$(cat "$file" | head -n 10000 | sha256sum | awk "{print \$1}")
    echo "$file_name" "$sha256sum" >> "$FILE_LIST_NEW"
done


##########################
# Match old/new ID pairs
##########################


echo ""
echo $(date)
echo "Sort the lists for later merge..."

echo "sha256 eid_old" | sed "s/ /\t/g" > "$FILE_LIST_OLD_SORTED"
cat "$FILE_LIST_OLD" | tail -n +2 | \
awk -v OFS='\t' '{print $2, $1}' | \
sed 's/_.*//g' | sort -k1 >> "$FILE_LIST_OLD_SORTED"

echo "sha256 eid_new" | sed "s/ /\t/g" > "$FILE_LIST_NEW_SORTED"
cat "$FILE_LIST_NEW" | tail -n +2 | \
awk -v OFS='\t' '{print $2, $1}' | \
sed 's/_.*//g' | sort -k1 >> "$FILE_LIST_NEW_SORTED"

echo "Match old/new ID pairs..."
# -a2: Output all the rows in the new dataset, no matter whether
#   corresponding entries are found in the old dataset
join -a2 "$FILE_LIST_OLD_SORTED" "$FILE_LIST_NEW_SORTED" > "$FILE_LIST_JOINED"
cat "$FILE_LIST_JOINED" | awk '{print $2,$3}' > "$FILE_ID_PAIRS"

echo ""
echo $(date)
echo "Done."
echo ""
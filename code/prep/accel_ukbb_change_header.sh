#!bin/sh -u
set -e

#####################
# Change the header row of 
#   UKBB+ACCEL dataset
#   from "eid something"
#   to "IID something"
#   to make it PLINK2-compatible  
#####################


source code/load_directory_tree_202307.sh

FILE_LIST_FILES="$DIR_DATA_ACCEL_UKBB"files.txt

echo ""
echo $(date) "Change the header row of UKBB+ACCEL dataset"
echo ""

I_FILE=1


# Display a message only if:
# - the integer is 1-digit, or
# - the integer is more than 1-digit and all its non-initial digits are 0
function check_int() {
  n_input=$1
  suffix=$2
  # Check if integer is 1-digit or all non-initial digits are 0
  if [ ${#1} -eq 1 ] || [[ ${1:1} =~ ^0+$ ]]; then
    echo $(date) "Processing No." "$n_input"":" "$suffix"
  fi
}


function func_main() {
  dir_source=$1
  dir_out=$2
  echo "Process" "$dir_source" "->" "$dir_out"
  for FILE_SOURCE in $(find $dir_source -type f -name "*.txt" | sort); do
    FILE_OUT=$(echo "$FILE_SOURCE" | sed "s|$dir_source|$dir_out|g")
    check_int "$I_FILE" "$FILE_OUT"

    HEADER=$(cat "$FILE_SOURCE" | head -n 1 | sed 's/^eid/IID/g')
    HEADER="FID ""$HEADER"
    HEADER=$(echo "$HEADER" | sed "s: :\t:g")
    echo "$HEADER" > "$FILE_OUT"
    tail -n +2 "$FILE_SOURCE" | awk -F'\t' -v OFS='\t' '{print $1,$0}' >> "$FILE_OUT"

    I_FILE=$(($I_FILE + 1))
  done
}

# func_main "$DIR_DATA_ACCEL_UKBB_SPLIT_ALL" "$DIR_DATA_ACCEL_UKBB_PLINK_ALL"

# echo ""
# echo $(date) "Export file list:" "$FILE_LIST_FILES"
# ls -1 "$DIR_DATA_ACCEL_UKBB_SPLIT_ALL" | sort > "$FILE_LIST_FILES"

func_main "$DIR_DATA_ACCEL_UKBB_SPLIT_ACCEL" "$DIR_DATA_ACCEL_UKBB_PLINK_ACCEL"

echo ""
echo $(date) "Done."
echo ""
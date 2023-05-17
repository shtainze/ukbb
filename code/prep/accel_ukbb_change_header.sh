#!bin/sh -u
set -e

#####################
# Change the header row of 
#   UKBB+ACCEL dataset
#   from "eid something"
#   to "IID something"
#   to make it PLINK2-compatible  
#####################


source code/load_directory_tree.sh


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


for FILE_SOURCE in $(find "$DIR_DATA_ACCEL_UKBB_SPLIT" -type f -name "*.txt" | sort); do
  FILE_OUT=$(echo "$FILE_SOURCE" | sed "s|$DIR_DATA_ACCEL_UKBB_SPLIT|$DIR_DATA_ACCEL_UKBB_PLINK|g")
  check_int "$I_FILE" "$FILE_OUT"

  HEADER=$(cat "$FILE_SOURCE" | head -n 1 | sed 's/^eid/IID/g')
  HEADER="FID ""$HEADER"
  HEADER=$(echo "$HEADER" | sed "s: :\t:g")
  echo "$HEADER" > "$FILE_OUT"
  tail -n +2 "$FILE_SOURCE" | awk -F'\t' -v OFS='\t' '{print $1,$0}' >> "$FILE_OUT"

  I_FILE=$(($I_FILE + 1))
done


echo ""
echo $(date) "Done."
echo ""
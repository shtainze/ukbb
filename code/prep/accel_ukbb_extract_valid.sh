#!bin/sh -u
set -e

#####################
# Process a limited set of the UKBB-ACCEL dataset
#####################


source code/load_directory_tree_202307.sh


echo ""
echo $(date) "Further process UKBB+ACCEL dataset"

DIR_OUT_1="$DIR_DATA_ACCEL_UKBB_PROCESSED""1180-0.0/all/"
mkdir -p "$DIR_OUT_1"
DIR_OUT_2="$DIR_DATA_ACCEL_UKBB_PROCESSED""1180-0.0/accel_only/"
mkdir -p "$DIR_OUT_2"

#####################
# Chronotype
#####################


function func_convert_chronotype() {
  dir_source=$1
  dir_out=$2
  file_source=$(find "$dir_source" -name "*_1180-0.0.txt")
  echo ""
  echo "Process" "$file_source" "->" "$dir_out"

  # 4-way distinction
  file_out="$dir_out""1234.txt"
  echo "4-way distinction:" "$file_out"
  cat "$file_source" | head -n 1 > "$file_out"
  cat "$file_source" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
    a = $2
    gsub("-1", "NA", a)
    gsub("-3", "NA", a)
    print $1,a
  }' >> "$file_out"

  # 2-way distinction
  # 1 & 2 → 1, 3&4 → 2
  file_out="$dir_out""12_34.txt"
  echo "2-way distinction:" "$file_out"
  cat "$file_source" | head -n 1 > "$file_out"
  cat "$file_source" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
    a = $2
    gsub("-1", "NA", a)
    gsub("-3", "NA", a)
    gsub("2", "1", a)
    gsub("3", "2", a)
    gsub("4", "2", a)
    print $1,a
  }' >> "$file_out"

  # Only "definite"
  # 2 & 3 → “NA”, 1 → 1, 4 → 2
  file_out="$dir_out""1_4.txt"
  echo "Only definite:" "$file_out"
  cat "$file_source" | head -n 1 > "$file_out"
  cat "$file_source" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
    a = $2
    gsub("-1", "NA", a)
    gsub("-3", "NA", a)
    gsub("2", "NA", a)
    gsub("3", "NA", a)
    gsub("4", "2", a)
    print $1,a
  }' >> "$file_out"
}

func_convert_chronotype "$DIR_DATA_ACCEL_UKBB_SPLIT_ALL" "$DIR_OUT_1"
func_convert_chronotype "$DIR_DATA_ACCEL_UKBB_SPLIT_ACCEL" "$DIR_OUT_2"

# Format for PLINK
echo ""
echo "Format for PLINK"

function func_format_plink() {
  dir_out=$1
  suffix=$2
  file_source="$dir_out""$suffix"".txt"
  file_out="$dir_out""$suffix""_plink.txt"
  echo "$file_source" "->" "$file_out"

  header=$(cat "$file_source" | head -n 1 | sed 's/^eid/IID/g')
  header="FID ""$header"
  header=$(echo "$header" | sed "s: :\t:g")
  echo "$header" > "$file_out"
  tail -n +2 "$file_source" | awk -F'\t' -v OFS='\t' '{print $1,$0}' >> "$file_out"
}

func_format_plink "$DIR_OUT_1" "1234"
func_format_plink "$DIR_OUT_1" "12_34"
func_format_plink "$DIR_OUT_1" "1_4"

func_format_plink "$DIR_OUT_2" "1234"
func_format_plink "$DIR_OUT_2" "12_34"
func_format_plink "$DIR_OUT_2" "1_4"


echo ""
echo $(date) "Done."
echo ""
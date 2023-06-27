#!bin/sh -u
set -e

#####################
# Process a limited set of the UKBB-ACCEL dataset
#####################


source code/load_directory_tree.sh


echo ""
echo $(date) "Further process UKBB+ACCEL dataset"
echo ""


SUFFIX="ukb671006_00901_1180-0.0"
FILE_SOURCE="$DIR_DATA_ACCEL_UKBB_SPLIT""$SUFFIX"".txt"
DIR_OUT="$DIR_DATA_ACCEL_UKBB_PROCESSED""$SUFFIX""/"
mkdir -p "$DIR_OUT"

# 4-way distinction
FILE_OUT="$DIR_OUT""1234.txt"
cat "$FILE_SOURCE" | head -n 1 > "$FILE_OUT"
cat "$FILE_SOURCE" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
  a = $2
  gsub("-1", "NA", a)
  gsub("-3", "NA", a)
  print $1,a
}' >> "$FILE_OUT"

# 2-way distinction
# 1 & 2 → 1, 3&4 → 2
FILE_OUT="$DIR_OUT""12_34.txt"
cat "$FILE_SOURCE" | head -n 1 > "$FILE_OUT"
cat "$FILE_SOURCE" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
  a = $2
  gsub("-1", "NA", a)
  gsub("-3", "NA", a)
  gsub("2", "1", a)
  gsub("3", "2", a)
  gsub("4", "2", a)
  print $1,a
}' >> "$FILE_OUT"

# Only "definite"
# 2 & 3 → “NA”, 1 → 1, 4 → 2
FILE_OUT="$DIR_OUT""1_4.txt"
cat "$FILE_SOURCE" | head -n 1 > "$FILE_OUT"
cat "$FILE_SOURCE" | tail -n +2 | awk -F'\t' -v OFS='\t' '{
  a = $2
  gsub("-1", "NA", a)
  gsub("-3", "NA", a)
  gsub("2", "NA", a)
  gsub("3", "NA", a)
  gsub("4", "2", a)
  print $1,a
}' >> "$FILE_OUT"

function single() {
  suffix=$1
  file_source="$DIR_OUT""$suffix"".txt"
  file_out="$DIR_OUT""$suffix""_plink.txt"

  header=$(cat "$file_source" | head -n 1 | sed 's/^eid/IID/g')
  header="FID ""$header"
  header=$(echo "$header" | sed "s: :\t:g")
  echo "$header" > "$file_out"
  tail -n +2 "$file_source" | awk -F'\t' -v OFS='\t' '{print $1,$0}' >> "$file_out"
}


single "1234"
single "12_34"
single "1_4"


echo ""
echo $(date) "Done."
echo ""
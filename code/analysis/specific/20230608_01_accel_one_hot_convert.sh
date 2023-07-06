#!bin/sh -u
set -e

#####################
# Extract one-hot expression
#   from the UKBB+ACCEL dataset
# And format for PLINK2
#   from "eid something"
#   to "FID IID something"
#####################


source code/load_directory_tree.sh


echo ""
echo $(date) "Change the header row of UKBB+ACCEL dataset"
echo ""


FILE_SOURCE="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230510_01_ACCEL_cancer/one_hot.csv"

DIR_OUT_1="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230608_01_accel_one_hot_convert/split/"
DIR_OUT_2="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230608_01_accel_one_hot_convert/for_plink/"
mkdir -p "$DIR_OUT_1"
mkdir -p "$DIR_OUT_2"

# Extract
for i in `seq 29 50`
do
  command="cat \"\$FILE_SOURCE\" | awk -F',' '{print \$$i}' | head -n 1"
  file_out="$DIR_OUT_1"$(eval $command)".txt"
  echo "Output:" "$file_out"
  command="cat \"\$FILE_SOURCE\" | awk -F',' -v OFS='\t' '{print \$1,\$$i}' > \"\$file_out\""
  eval $command
  #cat "$FILE_SOURCE" | awk -F',' '{print $1,$29,$50}' | head -n 1
done


# Convert to PLINK2-compatible format
for FILE_SOURCE in $(find "$DIR_OUT_1" -type f -name "*.txt" | sort); do
  FILE_OUT=$(echo "$FILE_SOURCE" | sed "s|$DIR_OUT_1|$DIR_OUT_2|g")
  echo "Process" "$FILE_SOURCE" ">" "$FILE_OUT"

  HEADER=$(cat "$FILE_SOURCE" | head -n 1 | sed 's/^eid/IID/g')
  HEADER="FID ""$HEADER"
  HEADER=$(echo "$HEADER" | sed "s: :\t:g")
  echo "$HEADER" > "$FILE_OUT"
  tail -n +2 "$FILE_SOURCE" | \
  awk -F'\t' -v OFS='\t' '{
    pheno=$2
    gsub("1", "2", pheno)
    gsub("0", "1", pheno)
    print $1,$1,pheno
  }' >> "$FILE_OUT"

done


echo ""
echo $(date) "Done."
echo ""
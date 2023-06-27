#!bin/sh -u
set -e

#####################
# Download & process UKBB tabular (= non-bulk) data
#####################


source code/load_directory_tree.sh


# #####################
# # Download
# #####################

# echo ""
# echo $(date) "Download UKBB software and meta-data..."


# mkdir -p "$DIR_SOFTWARE_UKBB"
# cd "$DIR_SOFTWARE_UKBB"
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbmd5 &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbconv &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/dconvert &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbunpack &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbfetch &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukblink &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/gfetch &
# wget -nd -q  biobank.ndph.ox.ac.uk/ukb/ukb/utilx/encoding.dat &

# wait
# rm -rf ./wget-*


#####################
#  Extract using UKBB tools
#####################


# Decrypt and decompress - output: "enc_ukb" file
echo $(date) "Decrypt and decompress"
cd "$DIR_DATA_UKBB_LATEST"
FILE_ENC=$(find ./ -name "*.enc")
FILE_KEY=$(find ./ -name "*.key")
ukbunpack "$FILE_ENC" "$FILE_KEY" &
wait

# Convert - output: csv, html, bulk list, R files
echo $(date) "Convert to readable formats"
cd "$DIR_DATA_UKBB_LATEST"
FILE_ENCUKB=$(find ./ -name "*.enc_ukb")
ukbconv "$FILE_ENCUKB" csv &
ukbconv "$FILE_ENCUKB" docs &
ukbconv "$FILE_ENCUKB" bulk &
ukbconv "$FILE_ENCUKB" r &
wait

# Including "encoding.dat" makes no change - already tried
# cp "$DIR_SOFTWARE_UKBB"encoding.dat ./
# "$DIR_SOFTWARE_UKBB"ukbconv ukb671006.enc_ukb csv -eencoding.dat &
# "$DIR_SOFTWARE_UKBB"ukbconv ukb671006.enc_ukb docs -eencoding.dat &
# "$DIR_SOFTWARE_UKBB"ukbconv ukb671006.enc_ukb bulk -eencoding.dat &
# "$DIR_SOFTWARE_UKBB"ukbconv ukb671006.enc_ukb r -eencoding.dat &
# wait


#####################
# Download the latest schema
#####################

echo $(date) "Download the latest schema"
cd "$DIR_HOME"
bash code/prep/ukbb_schema.sh latest


#####################
# Extract the not-yet-downloaded fraction
#####################

# Input
FILE_FIELDS_TABLE="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_exist_participants.txt
FILE_FIELDS_ALL="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_id_only.txt
FILE_FIELDS_CURRENT="$DIR_DATA_UKBB_LATEST"fields.ukb

# Intermediate output
FILE_FIELDS_TABLE_SORTED="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_exist_participants_sorted.txt
FILE_FIELDS_CURRENT_SORTED="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_id_only_allowed.txt
FILE_FIELDS_LEFTOVER="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_id_only_not_allowed.txt

# Final output - not-yet-downloaded fields and explanations
FILE_OUT="$DIR_DATA_UKBB_SCHEMA_PROCESSED"field_not_allowed.txt

echo $(date) "Extract the not-yet-downloaded fraction"
sort "$FILE_FIELDS_CURRENT" > "$FILE_FIELDS_CURRENT_SORTED"
echo "field_id" > "$FILE_FIELDS_LEFTOVER"
diff -c "$FILE_FIELDS_ALL" "$FILE_FIELDS_CURRENT_SORTED" | awk '{if($0 ~ "^- .*") print substr($0, 3, 10)}' >> "$FILE_FIELDS_LEFTOVER"

cat "$FILE_FIELDS_TABLE" | head -n 1 > "$FILE_FIELDS_TABLE_SORTED"
cat "$FILE_FIELDS_TABLE" | tail -n +2 | sort -t $'\t' -k1,1 >> "$FILE_FIELDS_TABLE_SORTED"
join --header -t $'\t' "$FILE_FIELDS_LEFTOVER" "$FILE_FIELDS_TABLE_SORTED" > "$FILE_OUT"

echo $(date) "Done output to:" "$FILE_OUT"

echo ""
echo $(date) "Done."
echo ""

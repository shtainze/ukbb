#!bin/sh -u
set -e

#####################
# Download & process UKBB tabular (= non-bulk) data
#####################


source code/load_directory_tree.sh


#####################
# Download
#####################

echo ""
echo $(date)
echo "Start downloading UKBB meta-data..."


rm -rf "$DIR_SOFTWARE_UKBB"
mkdir -p "$DIR_SOFTWARE_UKBB"
cd "$DIR_SOFTWARE_UKBB"
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbmd5 &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbconv &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/dconvert &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbunpack &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukbfetch &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/ukblink &
wget -nd -q  biobank.ndph.ox.ac.uk/ukb/util/gfetch &
wait
rm -rf ./wget-*


#####################
# Get only the practically available fields:
# - availability = not 1, 4, or 7 (= not available)
# - num_participants & item_count > 0
#####################


cd "$DIR_HOME"
"$DIR_SOFTWARE_UKBB"ukbunpack "$DIR_DATA_UKBB_4020457"ukb671006.enc "$DIR_DATA_UKBB_4020457"k62001r671006.key &
"$DIR_SOFTWARE_UKBB"ukbconv "$DIR_DATA_UKBB_4020457"ukb671006.enc_ukb csv &
"$DIR_SOFTWARE_UKBB"ukbconv "$DIR_DATA_UKBB_4020457"ukb671006.enc_ukb docs &
"$DIR_SOFTWARE_UKBB"ukbconv "$DIR_DATA_UKBB_4020457"ukb671006.enc_ukb bulk &

wait


echo ""
echo $(date)
echo "Done."
echo ""
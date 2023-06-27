#!bin/sh -u
set -e

#####################
# Download & process UKBB meta-data
#####################


source code/load_directory_tree.sh


MODE=$1 # Supplied from command line


# If $MODE is empty or "first", set default directory
if [ -z "$MODE" ]; then
    a=0
elif [ "$MODE" = "first" ]; then
    a=0
elif [ "$MODE" = "latest" ]; then
	a=1
else # Handle other cases
    a=0
fi

# Check the value of $a
if [ "$a" -eq 0 ]; then
    DIR_RAW="$DIR_HOME"data/ukbb/schema/raw/
    DIR_PROCESSED="$DIR_HOME"data/ukbb/schema/processed/
else
    DIR_RAW="$DIR_DATA_UKBB_SCHEMA_RAW"
    DIR_PROCESSED="$DIR_DATA_UKBB_SCHEMA_PROCESSED"
fi


echo "Output folders:"
echo "$DIR_RAW"
echo "$DIR_PROCESSED"

rm -rf "$DIR_RAW"
mkdir -p "$DIR_RAW"
rm -rf "$DIR_PROCESSED"
mkdir -p "$DIR_PROCESSED"


#####################
# Download
#####################

echo ""
echo $(date)
echo "Start downloading UKBB meta-data..."

cd "$DIR_RAW"
wget -nd -q -O field.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=1" &
wget -nd -q -O encoding.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=2" &
wget -nd -q -O category.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=3" &
wget -nd -q -O returns.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=4" &
wget -nd -q -O esimpint.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=5" &
wget -nd -q -O esimpstring.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=6" &
wget -nd -q -O esimpreal.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=7" &
wget -nd -q -O esimpdate.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=8" &
wget -nd -q -O instances.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=9" &
wget -nd -q -O insvalue.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=10" &
wget -nd -q -O ehierint.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=11" &
wget -nd -q -O ehierstring.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=12" &
wget -nd -q -O catbrowse.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=13" &
wget -nd -q -O recommended.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=14" &
wget -nd -q -O snps.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=15" &
wget -nd -q -O fieldsum.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=16" &
wget -nd -q -O record_table.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=17" &
wget -nd -q -O record_column.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=18" &
wget -nd -q -O publication.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=19" &
wget -nd -q -O esimptime.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=20" &
wget -nd -q -O schema.txt "biobank.ndph.ox.ac.uk/ukb/scdown.cgi?fmt=txt&id=999" &
wget -nd -q -O Data_Dictionary_Showcase.csv "biobank.ndph.ox.ac.uk/~bbdatan/Data_Dictionary_Showcase.csv" &
wget -nd -q -O Codings.csv "biobank.ndph.ox.ac.uk/~bbdatan/Codings.csv" &

wait
rm -rf ./wget-*


#####################
# Get only the practically available fields:
# - availability = not 1, 4, or 7 (= not available)
# - num_participants & item_count > 0
#####################

echo ""
echo $(date)
echo "Process the meta-data..."

cd "$DIR_HOME"
cat "$DIR_RAW"field.txt | \
awk -F'\t' -v OFS='\t' '{if (($3!=1) && ($3!=4) && ($3!=7) && ($24>0) && ($25>0)) {print $0}}' \
> "$DIR_PROCESSED"field_exist_participants.txt

# Extract field ids
cat "$DIR_PROCESSED"field_exist_participants.txt | \
tail -n +2 | awk -F'\t' '{print $1}' | sort \
> "$DIR_PROCESSED"field_id_only.txt


echo ""
echo $(date)
echo "Done."
echo ""
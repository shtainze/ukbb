#!bin/sh -u
set -e

##########################
# Gets a gene name-alias list
#   based on refseq annotation
##########################


source code/load_directory_tree_202307.sh


# Output folder
DIR_OUT="$DIR_REFSEQ"
# Source
URL_SOURCE="https://ftp.ncbi.nlm.nih.gov/refseq/H_sapiens/annotation/GRCh37_latest/refseq_identifiers/GRCh37_latest_genomic.gff.gz"
# Maximum trial number for wget failure
WGET_MAX_RETRY=3

# Downloaded file name (same as the last part of the Source)
FILE_GZ="$DIR_OUT""GRCh37_latest_genomic.gff.gz"
FILE_RAW="$DIR_OUT""GRCh37_latest_genomic.gff"
FILE_TEMP="$DIR_OUT""temp.txt"
FILE_OUT="$DIR_OUT""gene_full_name.txt"
# Same content, with Tab delimiters
FILE_OUT_TAB="$DIR_OUT""gene_full_name_tab.txt"


echo ""
echo $(date) "Downloading the RNA annotation data..."
echo ""

# Fetch the source data
while true; do
    # Run wget with timeout
    echo $(date) "Start downloading" "$URL_SOURCE"
    timeout 10 wget -c "$URL_SOURCE" -P "$DIR_OUT"

    # Check if wget was successful
    if [ $? -eq 0 ]; then
        echo ""
        echo $(date) "Download successful"
        break
    else
        echo ""
        echo $(date) "Download failed, retrying in 10 seconds"
        sleep 10
    fi
done


echo ""
echo $(date) "Extracting" "$FILE_GZ" "..."
unpigz -k "$FILE_GZ"

echo ""
echo $(date) "Extracting gene annotation info..."

# Preprocess
# Extract only the mRNA information on assembled chromosomes (“NC_”)
# Append gene names
# Replace chromosome names
tail "$FILE_RAW" -n +20 | awk -F'\t' -v OFS='\t' '{if (($1 ~ "NC_") && ($3 == "mRNA")) {print $0}}' | 
awk -F'\t' -v OFS='\t' '{
  match($9, /gene=(.*);product/, arr)
  print $0 "\t" arr[1] "\t" $1 "\t" $4 "\t" $5
}' |
awk -F'\t' -v OFS='\t' '{
gsub( /;inference=.*/, "", $10 )
gsub( "NC_000001.10", "1", $11 )
gsub( "NC_000002.11", "2", $11 )
gsub( "NC_000003.11", "3", $11 )
gsub( "NC_000004.11", "4", $11 )
gsub( "NC_000005.9", "5", $11 )
gsub( "NC_000006.11", "6", $11 )
gsub( "NC_000007.13", "7", $11 )
gsub( "NC_000008.10", "8", $11 )
gsub( "NC_000009.11", "9", $11 )
gsub( "NC_000010.10", "10", $11 )
gsub( "NC_000011.9", "11", $11 )
gsub( "NC_000012.11", "12", $11 )
gsub( "NC_000013.10", "13", $11 )
gsub( "NC_000014.8", "14", $11 )
gsub( "NC_000015.9", "15", $11 )
gsub( "NC_000016.9", "16", $11 )
gsub( "NC_000017.10", "17", $11 )
gsub( "NC_000018.9", "18", $11 )
gsub( "NC_000019.9", "19", $11 )
gsub( "NC_000020.10", "20", $11 )
gsub( "NC_000021.8", "21", $11 )
gsub( "NC_000022.10", "22", $11 )
gsub( "NC_000023.10", "X", $11 )
gsub( "NC_000024.9", "Y", $11 )
gsub( "NC_012920.1", "MT", $11 )
print $0
}' | awk -F'\t' -v OFS='\t' '{ # Extract gene names
match($9, /gene=(.*);product/, a1)
gsub( /;inference=.*/, "", a1[1] )
match($9, /product=(.*);/, a2)
gsub( /transcript variant.*/, "", a2[1] )
gsub( /%2C/, "_", a2[1] )
gsub( /_ /, "_", a2[1] )
gsub( /_$/, "", a2[1] )
gsub( /;.*/, "", a2[1] )
print a1[1], a2[1]
}' | uniq > "$FILE_TEMP"


# Sort
# Omit spaces in the names (which might cause error in the later analysis)
# And change the delimiter to space
echo "Gene Alias" > "$FILE_OUT"
cat "$FILE_TEMP" | sed 's/ /_/g' | sed 's/\t/ /g' | sort -k1,1 | tail -n +2 >> "$FILE_OUT"
cat "$FILE_OUT" | sed 's/ /\t/g' > "$FILE_OUT_TAB"

echo ""
echo $(date) "Done."
echo ""
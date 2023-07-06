#!bin/sh -u
set -e

#####################
# Download & extract MAGMA software and auxiliary files
# Extract "Gene ID" and "Gene names" from the 
#	gene annotation data for the later analyses
#####################


source code/load_directory_tree_202307.sh

rm -rf "$DIR_MAGMA"
mkdir -p "$DIR_MAGMA"


#####################
# 	Download & extract MAGMA auxiliary files
#####################

echo ""
echo $(date)
echo "Start downloading MAGMA and auxiliary files"
echo "Fetching from the web & extracting..."
echo ""

function single() {
	url=$1
	dir_out=$2
	file_zip=$(echo "$url" | sed 's/.*\///g')
	file_zip="$dir_out""$file_zip"
	
	echo $(date)
	echo "Processing:" "$url" "->" "$file_zip"
	wget -P "$dir_out" -q "$url"

	dir_out=$(echo "$file_zip" | sed 's/.zip//')
	mkdir -p "$dir_out"

	unzip "$file_zip" -d "$dir_out"
}


single "https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI38.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI37.3.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/aux_files/NCBI36.3.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/aux_files/dbsnp151.synonyms.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eur.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_afr.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_eas.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_sas.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_amr.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/ref_data/g1000_subpop.zip" "$DIR_MAGMA"
single "https://ctg.cncr.nl/software/MAGMA/prog/aux/posthoc_qc.zip" "$DIR_MAGMA"


#####################
#	Extract "Gene ID" and "Gene names" from the 
#		gene annotation data for later analyses
#####################

echo ""
echo $(date)
echo "Extract gene ID and gene names for later analyses..."
echo ""

function single() {
	file_source=$1

	echo $(date)
	echo "Process" "$file_source"

	# 1st file: Extract gene IDs and gene names
	file_out="$file_source"".extract.txt"
	header="GENE\tNAME"
	echo -e "$header" > "$file_out"
	cat "$file_source" | awk -F'\t' -v OFS='\t' '{print $1,$6}' >> "$file_out"

	# 2nd file: Sort by gene IDs
	file_out="$file_source"".extract_sorted.txt"
	header="GENE\tNAME"
	echo -e "$header" > "$file_out"
	cat "$file_source" | awk -F'\t' -v OFS='\t' '{print $1,$6}' | sort -k1,1 >> "$file_out"
}

single "$DIR_MAGMA""NCBI36.3/NCBI36.3.gene.loc"
single "$DIR_MAGMA""NCBI37.3/NCBI37.3.gene.loc"
single "$DIR_MAGMA""NCBI38/NCBI38.gene.loc"


echo ""
echo $(date)
echo "Done."
echo ""
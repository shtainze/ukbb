#!bin/sh -u
set -e

#####################
# Download & preprocess the dbSNP data
#####################


source code/load_directory_tree.sh


#####################
# Download
#####################


echo ""
echo $(date)
echo "Download dbSNP data..."
echo "Output folder:" "$DIR_DATA_DBSNP"

cd "$DIR_DATA_DBSNP"

# GRCh37/hg19
mkdir -p 25
cd 25
wget -q https://ftp.ncbi.nih.gov/snp/archive/b155/VCF/GCF_000001405.25.gz &
wget -q https://ftp.ncbi.nih.gov/snp/archive/b155/VCF/GCF_000001405.25.gz.tbi &
cd ..

# GRCh38/hg38
mkdir -p 39
cd 39
wget -q https://ftp.ncbi.nih.gov/snp/archive/b155/VCF/GCF_000001405.39.gz &
wget -q https://ftp.ncbi.nih.gov/snp/archive/b155/VCF/GCF_000001405.39.gz.tbi &
cd ..

wait


#####################
# Extracts per-chromosome dbSNP data
#####################

echo ""
echo $(date)
echo "Extract per chromosome..."
echo "By default, only GRCh37/hg19 is processed."
echo "If you want to use GRCh38/hg38, please rewrite the code."
echo "Output folder:" "$DIR_DATA_DBSNP_25_CHR"

FILE_SOURCE="$DIR_DATA_DBSNP_25"GCF_000001405.25.gz

tabix "$FILE_SOURCE" NC_000001.10 > "$DIR_DATA_DBSNP_25_CHR"1.csv &
tabix "$FILE_SOURCE" NC_000002.11 > "$DIR_DATA_DBSNP_25_CHR"2.csv &
tabix "$FILE_SOURCE" NC_000003.11 > "$DIR_DATA_DBSNP_25_CHR"3.csv &
tabix "$FILE_SOURCE" NC_000004.11 > "$DIR_DATA_DBSNP_25_CHR"4.csv &
tabix "$FILE_SOURCE" NC_000005.9 > "$DIR_DATA_DBSNP_25_CHR"5.csv &
tabix "$FILE_SOURCE" NC_000006.11 > "$DIR_DATA_DBSNP_25_CHR"6.csv &
tabix "$FILE_SOURCE" NC_000007.13 > "$DIR_DATA_DBSNP_25_CHR"7.csv &
tabix "$FILE_SOURCE" NC_000008.10 > "$DIR_DATA_DBSNP_25_CHR"8.csv &
tabix "$FILE_SOURCE" NC_000009.11 > "$DIR_DATA_DBSNP_25_CHR"9.csv &
tabix "$FILE_SOURCE" NC_000010.10 > "$DIR_DATA_DBSNP_25_CHR"10.csv &
tabix "$FILE_SOURCE" NC_000011.9 > "$DIR_DATA_DBSNP_25_CHR"11.csv &
tabix "$FILE_SOURCE" NC_000012.11 > "$DIR_DATA_DBSNP_25_CHR"12.csv &
tabix "$FILE_SOURCE" NC_000013.10 > "$DIR_DATA_DBSNP_25_CHR"13.csv &
tabix "$FILE_SOURCE" NC_000014.8 > "$DIR_DATA_DBSNP_25_CHR"14.csv &
tabix "$FILE_SOURCE" NC_000015.9 > "$DIR_DATA_DBSNP_25_CHR"15.csv &
tabix "$FILE_SOURCE" NC_000016.9 > "$DIR_DATA_DBSNP_25_CHR"16.csv &
tabix "$FILE_SOURCE" NC_000017.10 > "$DIR_DATA_DBSNP_25_CHR"17.csv &
tabix "$FILE_SOURCE" NC_000018.9 > "$DIR_DATA_DBSNP_25_CHR"18.csv &
tabix "$FILE_SOURCE" NC_000019.9 > "$DIR_DATA_DBSNP_25_CHR"19.csv &
tabix "$FILE_SOURCE" NC_000020.10 > "$DIR_DATA_DBSNP_25_CHR"20.csv &
tabix "$FILE_SOURCE" NC_000021.8 > "$DIR_DATA_DBSNP_25_CHR"21.csv &
tabix "$FILE_SOURCE" NC_000022.10 > "$DIR_DATA_DBSNP_25_CHR"22.csv &
tabix "$FILE_SOURCE" NC_000023.10 > "$DIR_DATA_DBSNP_25_CHR"23.csv &
tabix "$FILE_SOURCE" NC_000024.9 > "$DIR_DATA_DBSNP_25_CHR"24.csv &
tabix "$FILE_SOURCE" NC_012920.1 > "$DIR_DATA_DBSNP_25_CHR"25.csv &
wait


#####################
# Scan the dbSNP table, 
# Find rows with more than one "alt" entries, and
# Split such rows into multiple rows, each with just one "alt" entry
#####################


echo ""
echo $(date)
echo "Split dbSNP entries with multiple alt alleles..."
echo "Output folder:" "$DIR_DATA_DBSNP_25_SPLIT"


function single() {
	FILE_SOURCE=$1
	FILE_OUT=$2
	rm -f "$FILE_OUT"

	while read LINE_SOURCE; do
		IFS=$'\t' read -ra FIELDS <<< "$LINE_SOURCE"

		# If the split should be done
		if [[ ${FIELDS[4]} == *","* ]]; then
			ALT_ALLELES=${FIELDS[4]}
			IFS="," read -r -a ALT_ALLELES <<< "$ALT_ALLELES"
			for ALT in "${ALT_ALLELES[@]}"; do
			  # Replace the fifth field with the i-th character of the fifth field
			  FIELDS[4]=$ALT
			  # Join the fields back into a tab-separated string
			  LINE_OUTPUT=$(IFS=$'\t'; echo "${FIELDS[*]}")
			  # Print the modified line
			  echo "$LINE_OUTPUT" >> "$FILE_OUT"
			done
		else
			echo "$LINE_SOURCE" >> "$FILE_OUT"
		fi
	done < "$FILE_SOURCE"	
}


single "$DIR_DATA_DBSNP_25_CHR"1.csv "$DIR_DATA_DBSNP_25_SPLIT"1.csv &
single "$DIR_DATA_DBSNP_25_CHR"2.csv "$DIR_DATA_DBSNP_25_SPLIT"2.csv &
single "$DIR_DATA_DBSNP_25_CHR"3.csv "$DIR_DATA_DBSNP_25_SPLIT"3.csv &
single "$DIR_DATA_DBSNP_25_CHR"4.csv "$DIR_DATA_DBSNP_25_SPLIT"4.csv &
single "$DIR_DATA_DBSNP_25_CHR"5.csv "$DIR_DATA_DBSNP_25_SPLIT"5.csv &
single "$DIR_DATA_DBSNP_25_CHR"6.csv "$DIR_DATA_DBSNP_25_SPLIT"6.csv &
single "$DIR_DATA_DBSNP_25_CHR"7.csv "$DIR_DATA_DBSNP_25_SPLIT"7.csv &
single "$DIR_DATA_DBSNP_25_CHR"8.csv "$DIR_DATA_DBSNP_25_SPLIT"8.csv &
single "$DIR_DATA_DBSNP_25_CHR"9.csv "$DIR_DATA_DBSNP_25_SPLIT"9.csv &
single "$DIR_DATA_DBSNP_25_CHR"10.csv "$DIR_DATA_DBSNP_25_SPLIT"10.csv &
single "$DIR_DATA_DBSNP_25_CHR"11.csv "$DIR_DATA_DBSNP_25_SPLIT"11.csv &
single "$DIR_DATA_DBSNP_25_CHR"12.csv "$DIR_DATA_DBSNP_25_SPLIT"12.csv &
single "$DIR_DATA_DBSNP_25_CHR"13.csv "$DIR_DATA_DBSNP_25_SPLIT"13.csv &
single "$DIR_DATA_DBSNP_25_CHR"14.csv "$DIR_DATA_DBSNP_25_SPLIT"14.csv &
single "$DIR_DATA_DBSNP_25_CHR"15.csv "$DIR_DATA_DBSNP_25_SPLIT"15.csv &
single "$DIR_DATA_DBSNP_25_CHR"16.csv "$DIR_DATA_DBSNP_25_SPLIT"16.csv &
single "$DIR_DATA_DBSNP_25_CHR"17.csv "$DIR_DATA_DBSNP_25_SPLIT"17.csv &
single "$DIR_DATA_DBSNP_25_CHR"18.csv "$DIR_DATA_DBSNP_25_SPLIT"18.csv &
single "$DIR_DATA_DBSNP_25_CHR"19.csv "$DIR_DATA_DBSNP_25_SPLIT"19.csv &
single "$DIR_DATA_DBSNP_25_CHR"20.csv "$DIR_DATA_DBSNP_25_SPLIT"20.csv &
single "$DIR_DATA_DBSNP_25_CHR"21.csv "$DIR_DATA_DBSNP_25_SPLIT"21.csv &
single "$DIR_DATA_DBSNP_25_CHR"22.csv "$DIR_DATA_DBSNP_25_SPLIT"22.csv &
single "$DIR_DATA_DBSNP_25_CHR"23.csv "$DIR_DATA_DBSNP_25_SPLIT"23.csv &
single "$DIR_DATA_DBSNP_25_CHR"24.csv "$DIR_DATA_DBSNP_25_SPLIT"24.csv &
single "$DIR_DATA_DBSNP_25_CHR"25.csv "$DIR_DATA_DBSNP_25_SPLIT"25.csv &
wait


#####################
# Extract rsid and position info from dbSNP table
# Format to make MAGMA-compatible form:
# 	Example
# 	1:11063[b37]T,G 1 11063 rs561109771
#	chr:pos[b37]ref,alt chr pos rsid
#####################

echo ""
echo $(date)
echo "Extract rsid and position info from dbSNP table, and"
echo "Format to make MAGMA-compatible form..."
echo "Output folder:" "$DIR_DATA_DBSNP_25_RSID"

function single(){
	FILE_SOURCE=$1
	FILE_OUT=$2
	cat "$FILE_SOURCE" | awk -F'\t' '{
		# Convert chromosome names to number
		gsub( "NC_000001.10", "1", $1 )
		gsub( "NC_000002.11", "2", $1 )
		gsub( "NC_000003.11", "3", $1 )
		gsub( "NC_000004.11", "4", $1 )
		gsub( "NC_000005.9", "5", $1 )
		gsub( "NC_000006.11", "6", $1 )
		gsub( "NC_000007.13", "7", $1 )
		gsub( "NC_000008.10", "8", $1 )
		gsub( "NC_000009.11", "9", $1 )
		gsub( "NC_000010.10", "10", $1 )
		gsub( "NC_000011.9", "11", $1 )
		gsub( "NC_000012.11", "12", $1 )
		gsub( "NC_000013.10", "13", $1 )
		gsub( "NC_000014.8", "14", $1 )
		gsub( "NC_000015.9", "15", $1 )
		gsub( "NC_000016.9", "16", $1 )
		gsub( "NC_000017.10", "17", $1 )
		gsub( "NC_000018.9", "18", $1 )
		gsub( "NC_000019.9", "19", $1 )
		gsub( "NC_000020.10", "20", $1 )
		gsub( "NC_000021.8", "21", $1 )
		gsub( "NC_000022.10", "22", $1 )
		gsub( "NC_000023.10", "X", $1 )
		gsub( "NC_000024.9", "Y", $1 )
		gsub( "NC_012920.1", "MT", $1 )
		id=$1":"$2"[b37]"$4","$5
		print id,$3
	}' > "$FILE_OUT"
}

single "$DIR_DATA_DBSNP_25_SPLIT""1.csv" "$DIR_DATA_DBSNP_25_RSID""1.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""2.csv" "$DIR_DATA_DBSNP_25_RSID""2.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""3.csv" "$DIR_DATA_DBSNP_25_RSID""3.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""4.csv" "$DIR_DATA_DBSNP_25_RSID""4.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""5.csv" "$DIR_DATA_DBSNP_25_RSID""5.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""6.csv" "$DIR_DATA_DBSNP_25_RSID""6.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""7.csv" "$DIR_DATA_DBSNP_25_RSID""7.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""8.csv" "$DIR_DATA_DBSNP_25_RSID""8.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""9.csv" "$DIR_DATA_DBSNP_25_RSID""9.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""10.csv" "$DIR_DATA_DBSNP_25_RSID""10.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""11.csv" "$DIR_DATA_DBSNP_25_RSID""11.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""12.csv" "$DIR_DATA_DBSNP_25_RSID""12.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""13.csv" "$DIR_DATA_DBSNP_25_RSID""13.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""14.csv" "$DIR_DATA_DBSNP_25_RSID""14.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""15.csv" "$DIR_DATA_DBSNP_25_RSID""15.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""16.csv" "$DIR_DATA_DBSNP_25_RSID""16.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""17.csv" "$DIR_DATA_DBSNP_25_RSID""17.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""18.csv" "$DIR_DATA_DBSNP_25_RSID""18.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""19.csv" "$DIR_DATA_DBSNP_25_RSID""19.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""20.csv" "$DIR_DATA_DBSNP_25_RSID""20.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""21.csv" "$DIR_DATA_DBSNP_25_RSID""21.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""22.csv" "$DIR_DATA_DBSNP_25_RSID""22.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""23.csv" "$DIR_DATA_DBSNP_25_RSID""23.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""24.csv" "$DIR_DATA_DBSNP_25_RSID""24.txt"
single "$DIR_DATA_DBSNP_25_SPLIT""25.csv" "$DIR_DATA_DBSNP_25_RSID""25.txt"

echo ""
echo $(date)
echo "Done."
echo ""
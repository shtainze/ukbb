#!bin/sh -u
set -e


#####################
# Download & preprocess Pan-UKBB data
#####################


source code/load_directory_tree_202307.sh

# Output: only the column for file links
FILE_LINK="$DIR_DATA_PANUKBB_MANIFEST"download_links.tsv


#####################
# Download Pan-UKBB manifest file
#####################

# echo ""
# echo $(date)
# echo "Download Pan-UKBB manifest file..."

# wget -q https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_release/phenotype_manifest.tsv.bgz -P "$DIR_DATA_PANUKBB_MANIFEST"
# mv "$DIR_DATA_PANUKBB_MANIFEST"phenotype_manifest.tsv.bgz "$DIR_DATA_PANUKBB_MANIFEST"phenotype_manifest.tsv.gz

# echo ""
# echo $(date)
# echo "Extract..."
# gzip -d -k "$DIR_DATA_PANUKBB_MANIFEST"phenotype_manifest.tsv.gz

# # Extract the download links for Pan-UKBB per-phenotype files
# echo ""
# echo $(date)
# echo "Extract download links... "
# cat "$DIR_DATA_PANUKBB_MANIFEST"phenotype_manifest.tsv |
# awk -F'\t' '{gsub("s3://pan-ukb-us-east-1", "https://pan-ukb-us-east-1.s3.amazonaws.com", $77)
# print $77}' | tail -n +2 >> "$FILE_LINK"

# echo ""
# echo $(date)
# echo "Done."
# echo ""


#####################
# Downloads Pan-UKBB per-phenotype files
# The number of jobs is kept constant to $N_PARALLEL
#####################


# DIR_OUT="$DIR_DATA_PANUKBB_RAW"


# function single() {
# 	# Initialize a counter for the number of jobs
# 	JOB_COUNT=0

# 	# Count up iterations to produce intermediate outputs
# 	ITER=0

# 	IFS=","
# 	while read LINK; do
# 	  PREFIX=https://pan-ukb-us-east-1.s3.amazonaws.com/sumstats_flat_files/
# 	  FILE_DOWNLOADED=$(echo "$LINK" | sed "s|$PREFIX|$DIR_OUT|g")


# 	  # Print message for every 100 files
# 	  ITER=$((ITER + 1))
# 	  if [ $((ITER % 100)) -eq 0 ]; then
# 	    echo $(date) "$ITER", "$FILE_DOWNLOADED"
# 	  fi
	  

# 	  # Check if the file exists locally
# 	  if [ -f "$FILE_DOWNLOADED" ]; then
# 	    # Get the size of the local file
# 	    SIZE_LOCAL=$(stat --format=%s "$FILE_DOWNLOADED")
# 	    # Get the size of the file on the server
# 	    SIZE_SERVER=$(wget --spider --server-response "$LINK" 2>&1 | grep 'Content-Length' | awk '{print $2}')
# 	    # Compare the sizes
# 	    if [ "$SIZE_LOCAL" -ne "$SIZE_SERVER" ]; then
# 	      # The file was not fully downloaded, so resume the download
# 	      :
# 	      wget -q --continue "$LINK" -O "$FILE_DOWNLOADED" -P "$DIR_OUT" &
# 	      JOB_COUNT=$((JOB_COUNT+1))
# 	    else
# 	      # The file was fully downloaded
# 	      :
# 	    fi
# 	  else
# 	    # The file does not exist locally, so download it
# 	    :
# 	    wget -q "$LINK" -O "$FILE_DOWNLOADED" -P "$DIR_OUT" &
# 	    JOB_COUNT=$((JOB_COUNT+1))
# 	  fi


# 	  # If the job count has reached the maximum, wait for one job to finish
# 	  if [ "$JOB_COUNT" -ge "$N_PARALLEL" ]; then
# 	    wait -n
# 	    JOB_COUNT=$((JOB_COUNT-1))
# 	  fi

# 	done < "$FILE_LINK"

# 	wait
# }


# # Try 2 times to ensure that all files are correctly downloaded

# echo ""
# echo $(date)
# echo "Download Pan-UKBB per-phenotype files..."
# echo "Message will be shown for every 100 files"
# single

# echo ""
# echo $(date)
# echo "2nd trial to ensure complete download"
# single


#####################
# Extract
#####################


echo ""
echo $(date)
echo "Extract..."

for FILE_SOURCE in $(find "$DIR_DATA_PANUKBB_RAW" -type f -name "*.tsv.bgz" | sort); do
    FILE_OUT=$(echo "$FILE_SOURCE" | sed "s|$DIR_DATA_PANUKBB_RAW|$DIR_DATA_PANUKBB_EXTRACTED|g" | sed 's/.bgz//g')
    echo $(date) "Processing" "$FILE_SOURCE" "->" "$FILE_OUT"
    gzip -dc "$FILE_SOURCE" > "$FILE_OUT"
done

echo ""
echo $(date)
echo "Done."
echo ""


#!bin/sh -u
set -e

#####################
# This script does the following:
#   Make a list of SNP from a Pan-UKBB
#       per-phenotype summary statistics file
#   MAGMA annotation
# Ref: https://ctg.cncr.nl/software/MAGMA/doc/manual_v1.10.pdf
#
# Sliding windows = -100k (5'-end), +20k (3'-end)
#####################


source code/load_directory_tree.sh


#####################
# Set I/O
#####################

# Input - Summary statistics file
FILE_PVAL="$DIR_DATA_PANUKBB_EXTRACTED"continuous-1180-both_sexes.tsv
# Input - MAGMA gene annotation file
FILE_GENELOC="$DIR_MAGMA""NCBI37.3/NCBI37.3.gene.loc.extract_sorted.txt"
# Input - Reference genotype file
PATH_BFILE="$DIR_DATA_UKBB_GENOTYPE_BED""white-british"


# Output - relevant part of the summary statistics file
FILE_SNPLOC="$DIR_DATA_PANUKBB_MAGMA"snp_loc.txt
# Output - annotated SNPs per gene
PATH_ANNOTATE="$DIR_DATA_PANUKBB_MAGMA"gene_annotation_window_100_20
FILE_ANNOTATE="$DIR_DATA_PANUKBB_MAGMA""gene_annotation_window_100_20.genes.annot"


# MAGMA batch job number
# According to the manual, the maximum number is
#   somewhere in 25-30, regardless of the machine power
# In one of my trials, the maximum was 29
N_BATCH_MAGMA=30


# Maximum jobs
#   Maximum processes = MAGMA batch job number x Maximum jobs
# !Attention! Decide this number based on not only
#   the number of processors but also memory limit
MAX_JOBS=2

#####################
# Make a list of SNP from Pan-UKBB per-phenotype summary statistics
#####################

# echo ""
# echo $(date)
# echo "Making a list of SNP for --snp-loc input to MAGMA..."
# echo "$FILE_PVAL" "->" "$FILE_SNPLOC"

# # Make the SNP location file
# # The SNP location file should contain three columns:
# #   SNP ID, chromosome, and base pair position
# # Here, SNP IDs are newly generated, since they are  not given by Pan-UKBB
# #     Format:
# # Chr:pos[b37]ref,alt
# cat "$FILE_PVAL" | tail -n +2 | awk -F'\t' '{
#   id=$1":"$2"[b37]"$3","$4
#   print id,$1,$2
# }' > "$FILE_SNPLOC"


#####################
# MAGMA annotation
#####################

# echo ""
# echo $(date)
# echo "Start annotation using MAGMA"
# echo ""

# magma \
# --annotate \
# --snp-loc "$FILE_SNPLOC" \
# --gene-loc "$FILE_GENELOC" \
# --out "$PATH_ANNOTATE"


#####################
# Format each per-phenotype file for MAGMA input
#####################

# echo ""
# echo $(date)
# echo "Format for MAGMA..."

# for FILE_SOURCE in $(find "$DIR_DATA_PANUKBB_EXTRACTED" -type f -name "*.tsv" | sort); do
#   FILE_OUT=$(echo "$FILE_SOURCE" | sed "s|$DIR_DATA_PANUKBB_EXTRACTED|$DIR_DATA_PANUKBB_MAGMA_PERPHENO|g")
#   echo $(date) "$FILE_SOURCE" "->" "$FILE_OUT"

#   HEADER="SNP P"
#   echo "$HEADER" > "$FILE_OUT"

#   # Get the column number of "pval_EUR"
#   # Might be "neglog10_pval_EUR"
#   pos_EUR=`cat $FILE_SOURCE | head -n 1 | awk -F'\t' '{ for (i=1;i<=NF;i++) if ($i ~ "pval_EUR") {print i; exit}}'`

#   # Extract "SNP", "P"
#   # # Here, SNP IDs must be newly generated, since they are  not given by Pan-UKBB
#   #   Format:
#   # Chr:pos[b37]ref,alt
#   str_command="cat $FILE_SOURCE | tail -n +2 | awk -F'\t' '{ \
#     id=\$1\":\"\$2\"[b37]\"\$3\",\"\$4; \
#     pval=\$$pos_EUR; \
#     print id, 0.1^pval \
#   }' >> $FILE_OUT"
#   eval $str_command
# done


#####################
# MAGMA gene analysis and some postprocessing
#####################


echo ""
echo $(date)
echo "Conduct gene analysis using MAGMA..."
echo ""


# Extract population size from Pan-UKBB phenotype manifest
function panukbb_n_indiv(){
    pheno="$1"".tsv.bgz"
    file_manifest="$DIR_DATA_PANUKBB_MANIFEST""phenotype_manifest.tsv"

    # Get the column numbers of "filename" and "n_cases_EUR"
    pos_filename=`cat "$file_manifest" | head -n 1 | awk -F'\t' '{ for (i=1;i<=NF;i++) if ($i == "filename") {print i; exit}}'`
    pos_n=`cat "$file_manifest" | head -n 1 | awk -F'\t' '{ for (i=1;i<=NF;i++) if ($i == "n_cases_EUR") {print i; exit}}'`

    # Extract "n_cases_EUR"
    str_command="cat $file_manifest | tail -n +2 |
    awk -F'\t' -v pheno=\$pheno '{
        if(\$$pos_filename == pheno){
            n=\$$pos_n;
            print n
        }
    
    }'"
    n_indiv=$(eval $str_command)
    echo "$n_indiv"
}


# If there's a previous round of calculation done,
#   get the actual number of batches
#   which might be automatically reduced from the
#   given value "$N_BATCH_MAGMA" by MAGMA software
function get_n_batch() {
    dir=$1
    # Get the name of the log file, which includes the batch size
    file_log=$(find "$dir" -type f -name "*.batch1_*.log")
    # Extract the substring for the batch size
    n_batch=$(echo "$file_log" | sed 's/.*batch1_//g' | sed 's/.log//g')
    echo $n_batch
}


function single_magma(){
    # A flag to record that MAGMA is executed at least once
    flag_exec=0

    # Create an array to keep track of the background job PIDs
    declare -a pids

    N_BATCH_MAGMA_ACTUAL_TEMP=$(get_n_batch "$DIR_OUT")
    echo "" 1>&2
    if [ -z "$N_BATCH_MAGMA_ACTUAL_TEMP" ]; then
        N_BATCH_MAGMA_ACTUAL="$N_BATCH_MAGMA"
        echo "N_BATCH_MAGMA_ACTUAL has been set to the default value" "$N_BATCH_MAGMA" 1>&2
    else
        N_BATCH_MAGMA_ACTUAL="$N_BATCH_MAGMA_ACTUAL_TEMP"
        echo "N_BATCH_MAGMA_ACTUAL has been set to the value of" "$N_BATCH_MAGMA_ACTUAL" 1>&2
    fi


    for i in $(seq 1 "$N_BATCH_MAGMA_ACTUAL"); do
        echo "" 1>&2
        echo "Attempt calculation on subprocess" "$i" 1>&2
        # Check if the previous calculation was done
        #   = there're ".genes.out" and ".genes.raw" files
        #   "out.batch26_29.genes.out" for example
        file_1="$DIR_OUT""out.batch""$i""_""$N_BATCH_MAGMA_ACTUAL"".genes.out"
        file_2="$DIR_OUT""out.batch""$i""_""$N_BATCH_MAGMA_ACTUAL"".genes.raw"
        if ( test -e "$file_1" &&  test -e "$file_2" ); then
            echo "Skip because the calculation is complete" 1>&2
        else
            # Flag that a calculation is launched
            flag_exec=1
            echo "Proceed to (re-)calculation" 1>&2
            magma \
            --bfile "$PATH_BFILE" \
            --gene-annot "$FILE_ANNOTATE" \
            --pval "$FILE_SOURCE" N="$N_INDIV" \
            --batch "$i" "$N_BATCH_MAGMA_ACTUAL" \
            --out "$DIR_OUT"out 1>&2 &
            pids+=($!)
        fi
        sleep 1
    done

    # Wait for all background jobs to finish
    #   even if a background job fails
    for pid in "${pids[@]}"; do
        wait $pid || true
    done
    
    echo "" 1>&2
    echo "All batch jobs completed" 1>&2

    wait
    # Stands as a return value
    echo "$flag_exec"
}


function single_pheno() {
    SUFFIX=$(echo "$FILE_SOURCE" | sed 's/.*\///g' | sed 's/.tsv//g')
    # Output folder
    DIR_OUT="$DIR_ANALYSIS_PANUKBB_MAGMA""$SUFFIX""/"
    mkdir -p "$DIR_OUT"
    # Population size
    N_INDIV=$(panukbb_n_indiv "$SUFFIX")
    echo ""
    echo $(date) "Processing" "$SUFFIX" "with" "$N_INDIV" "samples (individuals)"

    # Main analysis
    # Automatically repeats until all of the batch is done
    N_ITER=1
    FLAG_EXEC=1
    while [ "$FLAG_EXEC" -eq 1 ]
    do
      echo ""
      echo $(date)
      echo "Iteration" "$N_ITER"
      FLAG_EXEC=($(single_magma))
      N_ITER=`expr $N_ITER + 1`
      sleep 1
    done

    # Merge the result
    echo ""
    echo "Merge the result of batch calculation"
    echo ""
    magma --merge "$DIR_OUT"out --out "$DIR_OUT"out.merged


    #####################
    # Add gene names to MAGMA gene analysis output
    #   The raw output only contains gene IDs.
    #   This part combines the raw output with
    #   the gene annotation file.
    #####################

    # The output produced just now
    FILE_GENE_ANALYSIS="$DIR_OUT"out.merged.genes.out
    # Output to be made - sorted
    FILE_GENE_ANALYSIS_SORTED="$DIR_OUT"out.merged.sorted.txt
    # Final output
    FILE_OUT="$DIR_OUT"out.with_gene_name.txt

    echo ""
    echo $(date) "Postprocessing..."
    # The numerous `sed` commands look silly, but somehow `sed "s/ {2}/ /g"` doesn't work
    cat "$FILE_GENE_ANALYSIS" | head -n 1 | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" > "$FILE_GENE_ANALYSIS_SORTED"
    cat "$FILE_GENE_ANALYSIS" | tail -n +2 | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sort -k1,1 >> "$FILE_GENE_ANALYSIS_SORTED"
    join --header -a 1 "$FILE_GENELOC" "$FILE_GENE_ANALYSIS_SORTED" > "$FILE_OUT"
    echo $(date) "Postprocessing done."
    echo ""
    echo "----------------------------"
}


# Reference genotype file
PATH_BFILE="$DIR_DATA_UKBB_GENOTYPE_BED"white_british

# Job count
JOB_COUNT=0

for FILE_SOURCE in $(find "$DIR_DATA_PANUKBB_MAGMA_PERPHENO" -type f -name "*.tsv" | sort); do
    single_pheno "$FILE_SOURCE" &
    sleep 60
    JOB_COUNT=$((JOB_COUNT+1))
    # If the job count has reached the maximum, wait for one job to finish
    if [ "$JOB_COUNT" -ge "$MAX_JOBS" ]; then
      wait -n
      JOB_COUNT=$((JOB_COUNT-1))
    fi 
done

echo ""
echo $(date)
echo "Done."
echo ""






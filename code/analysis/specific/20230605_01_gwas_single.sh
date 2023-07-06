#!bin/sh -u
set -e


#####################
# Conduct GWAS using PLINK2
# Calculate gene-based P-values using MAGMA
# CAUTION! $FILE_PHENO and $DIR_OUT must be
#   supplied through command line
#####################


source code/load_directory_tree_202305.sh

# Supplied through command line
# Input: phenotype
FILE_PHENO=$1
# Output folder
DIR_OUT=$2
# Mode - "small" or "large"
MODE=$3


if [ "$MODE" = "large" ]; then
    # Input: PLINK2-related
    # Input: genotype
    PATH_GENO="$DIR_DATA_UKBB_GENOTYPE_2""white_british/white_british"
    # Input: covariates
    FILE_COVAR="$DIR_DATA_ACCEL_UKBB_COVAR_2""covar_age_sex_combination_pc10.txt"
    # Input: allele frequency
    FILE_FREQ="$PATH_GENO"".freq.afreq"
    # Input: Reference genotype file
    PATH_BFILE="$PATH_GENO"".bed"
    # MAGMA batch job number
    # Theoretical limit is 29 or 30
    # Practical limit is much lower due to machine memory size
    N_BATCH_MAGMA=3
fi

if [ "$MODE" = "small" ]; then
    # Input: PLINK2-related
    # Input: genotype
    PATH_GENO="$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british
    # Input: covariates
    FILE_COVAR="$DIR_DATA_ACCEL_UKBB_COVAR""covar_age_sex_combination_pc10.txt"
    # Input: allele frequency
    FILE_FREQ="$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.freq.afreq"
    # Input: Reference genotype file
    PATH_BFILE="$DIR_DATA_UKBB_GENOTYPE_BED""white_british"
    # MAGMA batch job number
    # Theoretical limit is 29 or 30
    # Practical limit is much lower due to machine memory size
    N_BATCH_MAGMA=10
fi

# Input: MAGMA-related
# Input: MAGMA gene annotation file
FILE_GENELOC="$DIR_MAGMA""NCBI37.3/NCBI37.3.gene.loc"
# Input: MAGMA gene name file
FILE_GENENAME="$DIR_MAGMA""NCBI37.3/NCBI37.3.gene.loc.extract_sorted.txt"
# Input: List of gene names, abbreviation & full
FILE_ALIAS="$DIR_REFSEQ""gene_full_name_tab_manually_augmented.txt"


PATH_OUT="$DIR_OUT""out"
DIR_OUT_MAGMA="$DIR_OUT""magma/"
mkdir -p "$DIR_OUT"
mkdir -p "$DIR_OUT_MAGMA"


# Intermediate output: SNP info extracted from PLINK2 output
FILE_SNPLOC="$DIR_OUT""snploc.txt"
# Intermediate output: annotated SNPs per gene
PATH_ANNOTATE="$DIR_OUT"gene_annotation_window_100_20
FILE_ANNOTATE="$PATH_ANNOTATE"".genes.annot"
# Intermediate output: only "SNP" and "P" columns extracted from PLINK2 output
FILE_PVAL_MAGMA="$DIR_OUT""pval_for_magma.txt"
# Intermediate output: MAGMA analysis
FILE_GENE_ANALYSIS="$DIR_OUT_MAGMA"out.merged.genes.out
# Intermediate output: MAGMA analysis, sorted
FILE_GENE_ANALYSIS_SORTED="$DIR_OUT_MAGMA"out.merged.sorted.txt
# Intermediate output: MAGMA analysis, combined with gene names
FILE_GENE_ANALYSIS_WITH_NAME="$DIR_OUT_MAGMA"out.with_gene_name.txt
# Intermediate output: MAGMA analysis, formatted for later join
FILE_GENE_ANALYSIS_WITH_NAME_2="$DIR_OUT_MAGMA""temp.txt"

# Final output: fully annotated MAGMA output
FILE_OUT_FINAL="$DIR_OUT_MAGMA""gene_pheno_pval_list_annotated.csv"


#####################
# GWAS using PLINK2
#####################

# echo ""
# echo $(date) "Start GWAS using PLINK2"
# echo ""

# plink2 \
# --pfile "$PATH_GENO" \
# --glm no-firth \
# --covar "$FILE_COVAR" \
# --covar-variance-standardize \
# --vif 999999 \
# --adjust \
# --read-freq "$FILE_FREQ" \
# --pheno "$FILE_PHENO" \
# --threads 64 \
# --out "$PATH_OUT"


#####################
# Make a list of SNP from summary statistics
#####################

echo ""
echo $(date) "Make a list of SNP for --snp-loc input to MAGMA"

FILE_PVAL=$(find "$DIR_OUT" -name "*.adjusted")
echo "Input:" "$FILE_PVAL"
echo "Output:" "$FILE_SNPLOC"

echo "$FILE_PVAL" "->" "$FILE_SNPLOC"


# Make the SNP location file
# The SNP location file should contain three columns:
#   SNP ID, chromosome, and base pair position
# Here, SNP IDs are newly generated, since they are  not given by Pan-UKBB
#   Format:
# 		Chr:pos[b37]ref,alt
#	Example:
#		1:182573227[b37]T,C 
cat "$FILE_PVAL" | tail -n +2 | awk -F'\t' '{
	split($2,a,":")
	split(a[2],b,"\\[")
	print $2,$1,b[1]
}' > "$FILE_SNPLOC"


#####################
# MAGMA annotation
#####################

echo ""
echo $(date) "Annotation of gene locations using MAGMA"
echo ""

magma \
--annotate \
--snp-loc "$FILE_SNPLOC" \
--gene-loc "$FILE_GENELOC" \
--out "$PATH_ANNOTATE"


#####################
# Format per-phenotype file for MAGMA input
#####################

echo ""
echo $(date) "Format the per-phenotype file for MAGMA input"
echo "Input:" "$FILE_PVAL"
echo "Output:" "$FILE_PVAL_MAGMA"

FILE_PVAL=$(find "$DIR_OUT" -name "*.adjusted")

echo $(date) "$FILE_PVAL" "->" "$FILE_PVAL_MAGMA"

HEADER="SNP P"
echo "$HEADER" > "$FILE_PVAL_MAGMA"
# Extract "SNP", "P"
# # Here, SNP IDs must be newly generated, since they are  not given by Pan-UKBB
#   Format:
# Chr:pos[b37]ref,alt
cat "$FILE_PVAL" | tail -n +2 | awk -F'\t' '{ \
print $2,$4
}' >> "$FILE_PVAL_MAGMA"


#####################
# MAGMA gene analysis and some postprocessing
#####################

echo ""
echo $(date) "Conduct gene analysis using MAGMA"
echo ""


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
	dir_out_magma=$1

    # A flag to record that MAGMA is executed at least once
    flag_exec=0

    # Create an array to keep track of the background job PIDs
    declare -a pids

    N_BATCH_MAGMA_ACTUAL_TEMP=$(get_n_batch "$dir_out_magma")
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
        file_1="$dir_out_magma""out.batch""$i""_""$N_BATCH_MAGMA_ACTUAL"".genes.out"
        file_2="$dir_out_magma""out.batch""$i""_""$N_BATCH_MAGMA_ACTUAL"".genes.raw"
        if ( test -e "$file_1" &&  test -e "$file_2" ); then
            echo "Skip because the calculation is complete" 1>&2
        else
            # Flag that a calculation is launched
            flag_exec=1
            echo "Proceed to (re-)calculation" 1>&2
            magma \
            --bfile "$PATH_BFILE" \
            --gene-annot "$FILE_ANNOTATE" \
            --pval "$FILE_PVAL_MAGMA" N="$N_INDIV" \
            --batch "$i" "$N_BATCH_MAGMA_ACTUAL" \
            --out "$dir_out_magma"out 1>&2 &
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


# Population size
# Get from the PLINK log file
#   Example:
#   384235 samples (208456 females, 175779 males; 384235 founders) loaded from
N_INDIV=$(cat "$PATH_OUT".log | awk '{if($0 ~ "sample.*loaded") print $0}' | sed 's/ samples.*//g')
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
  FLAG_EXEC=($(single_magma "$DIR_OUT_MAGMA"))
  N_ITER=`expr $N_ITER + 1`
  sleep 1
done

# Merge the result
echo ""
echo "Merge the result of batch calculation"
echo ""
magma --merge "$DIR_OUT_MAGMA"out --out "$DIR_OUT_MAGMA"out.merged


#####################
# Add gene names & aliases
#   The raw output only contains gene IDs.
#   This part combines the raw output with
#   the gene annotation files.
#####################


echo ""
echo $(date) "Sort the result"
echo "Output:" "$FILE_GENE_ANALYSIS_SORTED"
# The numerous `sed` commands look silly, but somehow `sed "s/ {2}/ /g"` doesn't work
cat "$FILE_GENE_ANALYSIS" | head -n 1 | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" > "$FILE_GENE_ANALYSIS_SORTED"
cat "$FILE_GENE_ANALYSIS" | tail -n +2 | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sed "s/  / /g" | sort -k1,1 >> "$FILE_GENE_ANALYSIS_SORTED"
sleep 1

echo ""
echo $(date) "Join with gene name file:" "$FILE_GENENAME"
echo "Output:" "$FILE_GENE_ANALYSIS_WITH_NAME"
join --header -a 1 "$FILE_GENENAME" "$FILE_GENE_ANALYSIS_SORTED" > "$FILE_GENE_ANALYSIS_WITH_NAME"
sleep 1

echo ""
echo $(date) "Sort"
echo "Output:" "$FILE_GENE_ANALYSIS_WITH_NAME_2"
# Format the files
#   Delimiters to Tab
#   Sort
cat "$FILE_GENE_ANALYSIS_WITH_NAME" | head -n 1 | sed "s/,/\t/g" > "$FILE_GENE_ANALYSIS_WITH_NAME_2"
cat "$FILE_GENE_ANALYSIS_WITH_NAME" | tail -n +2 | sed "s/,/\t/g" | sort -k2,2 >> "$FILE_GENE_ANALYSIS_WITH_NAME_2"

sleep 1

# Join
# Outer join (-a 1) to keep all the entries in the first file
echo ""
echo $(date) "Join with gene alias file:" "$FILE_ALIAS"
echo "Output:" "$FILE_OUT_FINAL"
# join --header -a 1 -1 2 \
# "$FILE_GENE_ANALYSIS_WITH_NAME_2" "$FILE_ALIAS" | \
# sed 's/ /,/g' > "$FILE_OUT_FINAL"

join --header -a 1 -2 2 \
"$FILE_ALIAS" "$FILE_GENE_ANALYSIS_WITH_NAME_2" | \
sed 's/ /,/g' > "$FILE_OUT_FINAL"

echo ""
echo $(date) "Done."
echo ""
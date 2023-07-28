#!bin/sh -u
set -e


#####################
# Wrapper of gwas_single.sh
#   to conduct multiple GWAS with the same pipeline
#####################


source code/load_directory_tree_202307.sh


function func_single (){
    file_pheno=$1 # Phenotype file location
    suffix=$2 # Output folder suffix (arbitrary)
    mode=$3 # "small" or "large"
    file_code="$DIR_CODE_ANALYSIS_SPECIFIC""20230705_01_01_gwas_single.sh"
    dir_out="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230705_01_gwas/""$suffix""/"
    mkdir -p "$dir_out"
    file_log="$dir_out""log_""$(date +"%Y%m%d_%H%M%S")"".log"
    bash "$file_code" "$file_pheno" "$dir_out" "$mode" > "$file_log" 2>&1
}


# Chronotype x only individuals with ACCEL data
FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PROCESSED""1180-0.0/accel_only/1234_plink.txt"
func_single "$FILE_PHENO" "accel_only" "small"

# Chronotype x all White British population
FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PROCESSED""1180-0.0/all/1234_plink.txt"
func_single "$FILE_PHENO" "all" "small"
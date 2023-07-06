#!bin/sh -u
set -e


#####################
# Wrapper of 20230529_01_gwas_single.sh
#   to conduct multiple GWAS with the same pipeline
#####################


source code/load_directory_tree_202305.sh


function single (){
    file_pheno=$1 # Phenotype file location
    suffix=$2 # Output folder suffix (arbitrary)
    mode=$3 # "small" or "large"
    file_code="$DIR_CODE_ANALYSIS_SPECIFIC""20230605_01_gwas_single.sh"
    dir_out="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230605_01_gwas/""$suffix""/"
    mkdir -p "$dir_out"
    file_log="$dir_out""log_""$(date +"%Y%m%d_%H%M%S")"".log"
    bash "$file_code" "$file_pheno" "$dir_out" "$mode" > "$file_log" 2>&1
}


# Chronotype - large
DIR_SOURCE="$DIR_DATA_ACCEL_UKBB_PROCESSED""ukb671006_00901_1180-0.0/"
single "$DIR_SOURCE""1234_plink.txt" "1180-0.0_Chronotype_fourway_large" "large"
# single "$DIR_SOURCE""12_34_plink.txt" "1180-0.0_Chronotype_twoway_large" "large"
# single "$DIR_SOURCE""1_4_plink.txt" "1180-0.0_Chronotype_definite_large" "large"

# # BMI - large
# DIR_SOURCE="$DIR_DATA_ACCEL_UKBB_PLINK"
# single "$DIR_SOURCE""ukb671006_12155_21001-0.0.txt" "21001-0.0_BMI_large" "large"
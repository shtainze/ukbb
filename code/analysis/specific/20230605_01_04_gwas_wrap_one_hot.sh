#!bin/sh -u
set -e


#####################
# Wrapper of 20230529_01_gwas_single.sh
#   to conduct multiple GWAS with the same pipeline
#####################


source code/load_directory_tree.sh


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


function single2(){
    DIR_SOURCE="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230608_01_accel_one_hot_convert/for_plink/"
    single "$DIR_SOURCE""$1"".txt" "$1" "small"
}

#single2 ukb671006_28475_group_eid_old_1
#single2 ukb671006_28475_group_eid_old_2a
#single2 ukb671006_28475_group_eid_old_2b
single2 ukb671006_28475_group_eid_old_3a
single2 ukb671006_28475_group_eid_old_3b
single2 ukb671006_28475_group_eid_old_4a
single2 ukb671006_28475_group_eid_old_4b
single2 ukb671006_28475_group_eid_old_5
single2 ukb671006_28476_abnormal_group_eid_old_3b-1
single2 ukb671006_28476_abnormal_group_eid_old_3b-2
single2 ukb671006_28476_abnormal_group_eid_old_4b-1
single2 ukb671006_28476_abnormal_group_eid_old_4b-2
single2 ukb671006_28476_abnormal_group_eid_old_4b-3
single2 ukb671006_28476_abnormal_group_eid_old_4b-4
single2 ukb671006_28476_abnormal_group_eid_old_4b-5
single2 ukb671006_28476_abnormal_group_eid_old_4b-6
single2 ukb671006_28476_abnormal_group_eid_old_NA
single2 ukb671006_28480_group_five_1
single2 ukb671006_28480_group_five_2
single2 ukb671006_28480_group_five_3
single2 ukb671006_28480_group_five_4
single2 ukb671006_28480_group_five_5
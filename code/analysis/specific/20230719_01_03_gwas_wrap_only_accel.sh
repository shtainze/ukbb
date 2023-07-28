#!bin/sh -u
set -e


#####################
# Wrapper of gwas_single.sh
#   to conduct multiple GWAS with the same pipeline
#####################


source code/load_directory_tree_202307.sh


function func_single (){
    file_pheno=$1 # Phenotype file location
    suffix=$2_$3 # Output folder suffix (arbitrary)
    pheno_name=$3 # Select phenotype
    file_code="$DIR_CODE_ANALYSIS_SPECIFIC""20230719_01_01_gwas_single.sh"
    dir_out="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230719_01_gwas/""$suffix""/"
    mkdir -p "$dir_out"
    file_log="$dir_out""log_""$(date +"%Y%m%d_%H%M%S")"".log"
    bash "$file_code" "$file_pheno" "$dir_out" "$pheno_name" > "$file_log" 2>&1 || true
}

# DIR_PHENO="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230706_01_ACCEL_dimension_reduction/factor_analysis_20230719_1502/"

# # ACCEL x only individuals with ACCEL data
# FILE_PHENO="$DIR_PHENO""none_6_for_plink.txt"
# func_single "$FILE_PHENO" "none" "ML1"
# func_single "$FILE_PHENO" "none" "ML2"
# func_single "$FILE_PHENO" "none" "ML3"
# func_single "$FILE_PHENO" "none" "ML4"
# func_single "$FILE_PHENO" "none" "ML5"
# func_single "$FILE_PHENO" "none" "ML6"

# FILE_PHENO="$DIR_PHENO""oblimin_5_for_plink.txt"
# func_single "$FILE_PHENO" "oblimin" "ML1"
# func_single "$FILE_PHENO" "oblimin" "ML2"
# func_single "$FILE_PHENO" "oblimin" "ML3"
# func_single "$FILE_PHENO" "oblimin" "ML4"
# func_single "$FILE_PHENO" "oblimin" "ML5"

# FILE_PHENO="$DIR_PHENO""promax_4_for_plink.txt"
# func_single "$FILE_PHENO" "promax" "ML1"
# func_single "$FILE_PHENO" "promax" "ML2"
# func_single "$FILE_PHENO" "promax" "ML3"
# func_single "$FILE_PHENO" "promax" "ML4"

# FILE_PHENO="$DIR_PHENO""varimax_5_for_plink.txt"
# func_single "$FILE_PHENO" "varimax" "ML1"
# func_single "$FILE_PHENO" "varimax" "ML2"
# func_single "$FILE_PHENO" "varimax" "ML3"
# func_single "$FILE_PHENO" "varimax" "ML4"
# func_single "$FILE_PHENO" "varimax" "ML5"


function single2(){
    pheno=$1
    file_pheno="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230608_01_accel_one_hot_convert/for_plink/""$pheno"".txt"
    func_single "$file_pheno" "cluster_onehot" "$pheno"
}

# single2 ukb671006_28475_group_eid_old_1
# single2 ukb671006_28475_group_eid_old_2a
# single2 ukb671006_28475_group_eid_old_2b
# single2 ukb671006_28475_group_eid_old_3a
# single2 ukb671006_28475_group_eid_old_3b
# single2 ukb671006_28475_group_eid_old_4a
# single2 ukb671006_28475_group_eid_old_4b
# single2 ukb671006_28475_group_eid_old_5
# single2 ukb671006_28476_abnormal_group_eid_old_3b-1
# single2 ukb671006_28476_abnormal_group_eid_old_3b-2
# single2 ukb671006_28476_abnormal_group_eid_old_4b-1
# single2 ukb671006_28476_abnormal_group_eid_old_4b-2
# single2 ukb671006_28476_abnormal_group_eid_old_4b-3
# single2 ukb671006_28476_abnormal_group_eid_old_4b-4
# single2 ukb671006_28476_abnormal_group_eid_old_4b-5
# single2 ukb671006_28476_abnormal_group_eid_old_4b-6
# single2 ukb671006_28480_group_five_2
# single2 ukb671006_28480_group_five_3
# single2 ukb671006_28480_group_five_4


function single3 (){
    file_pheno=$1
    pheno=$2
    file_pheno="$DIR_DATA_ACCEL_UKBB_PLINK_ACCEL""$file_pheno"".txt"
    func_single "$file_pheno" "21index" "$pheno"
}

single3 "30816_ST_long_mean" "ST_long_mean"
single3 "30817_ST_long_sd" "ST_long_sd"
single3 "30818_WT_long_mean" "WT_long_mean"
single3 "30819_WT_long_sd" "WT_long_sd"
single3 "30820_ST_short_mean" "ST_short_mean"
single3 "30821_ST_short_sd" "ST_short_sd"
single3 "30822_WT_short_mean" "WT_short_mean"
single3 "30823_WT_short_sd" "WT_short_sd"
single3 "30824_long_window_len_mean" "long_window_len_mean"
single3 "30825_long_window_len_sd" "long_window_len_sd"
single3 "30826_long_window_num_mean" "long_window_num_mean"
single3 "30827_long_window_num_sd" "long_window_num_sd"
single3 "30828_short_window_len_mean" "short_window_len_mean"
single3 "30829_short_window_len_sd" "short_window_len_sd"
single3 "30830_short_window_num_mean" "short_window_num_mean"
single3 "30831_short_window_num_sd" "short_window_num_sd"
single3 "30832_phase_mean" "phase_mean"
single3 "30833_phase_sd" "phase_sd"
single3 "30834_max_period" "max_period"
single3 "30835_amplitude" "amplitude"
single3 "30836_sleep_percentage" "sleep_percentage"


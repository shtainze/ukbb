#!bin/sh -u
set -e


#####################
# Wrapper of 20230526_01_gwas_single.sh
#   to conduct multiple GWAS with the same pipeline
#####################


source code/load_directory_tree.sh


# # 1180 chronotype
# FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PLINK""ukb671006_00901_1180-0.0.txt"
# DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230526_01_gwas/1180_chronotype/"
# mkdir -p "$DIR_OUT"
# # Call "20230526_01_gwas_single.sh", and output all the log to file
# bash "$DIR_CODE_ANALYSIS_SPECIFIC""20230526_01_gwas_single.sh" "$FILE_PHENO" "$DIR_OUT" > "$DIR_OUT""20230526_01_gwas_wrap.log"


# ACCEL
function single (){
    suffix=$1
    FILE_PHENO="$DIR_DATA_ACCEL_UKBB_PLINK""ukb671006_""$suffix"".txt"
    DIR_OUT="$DIR_ANALYSIS_RESULT_SPECIFIC""analysis_20230526_01_gwas/""$suffix""/"
    mkdir -p "$DIR_OUT"
    FILE_LOG="$DIR_OUT""20230526_01_gwas_wrap_""$(date +"%Y%m%d_%H%M%S")"".log"
    bash "$DIR_CODE_ANALYSIS_SPECIFIC""20230526_01_gwas_single.sh" "$FILE_PHENO" "$DIR_OUT" > "$FILE_LOG" 2>&1
}

# single "00901_1180-0.0"
# single "28450_ST_long_mean"
# single "28451_ST_long_sd"
# single "28452_WT_long_mean"
# single "28453_WT_long_sd"
# single "28454_ST_short_mean"
# single "28455_ST_short_sd"
# single "28456_WT_short_mean"
# single "28457_WT_short_sd"
# single "28458_long_window_len_mean"
# single "28459_long_window_len_sd"
# single "28460_long_window_num_mean"
# single "28461_long_window_num_sd"
# single "28462_short_window_len_mean"
# single "28463_short_window_len_sd"

single "28464_short_window_num_mean"
single "28465_short_window_num_sd"
single "28466_phase_mean"
single "28467_phase_sd"
single "28468_max_period"
single "28469_amplitude"
single "28470_sleep_percentage"

# single "28474_cluster"
# single "28475_group_eid_old"
# single "28476_abnormal_group_eid_old"
# single "28480_group_five"
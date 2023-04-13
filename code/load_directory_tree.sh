#!bin/sh -u
set -e


#####################
# Usage:
# (Set the current directory to the parent folder!)
# source code/load_directory_tree.sh
#####################


#####################
# Definition of directory structure
#####################

DIR_HOME=$(pwd)/

# Data

DIR_DATA_UKBB_SCHEMA_RAW="$DIR_HOME"data/ukbb/schema/raw/
mkdir -p "$DIR_DATA_UKBB_SCHEMA_RAW"

DIR_DATA_UKBB_SCHEMA_PROCESSED="$DIR_HOME"data/ukbb/schema/processed/
mkdir -p "$DIR_DATA_UKBB_SCHEMA_PROCESSED"

DIR_SOFTWARE="$DIR_HOME"software/
mkdir -p "$DIR_SOFTWARE"
DIR_SOFTWARE_UKBB="$DIR_HOME"software/ukbb/
mkdir -p "$DIR_SOFTWARE_UKBB"

DIR_DATA_UKBB_34134="$DIR_HOME"data/ukbb/0000000_34134_axivity/
mkdir -p "$DIR_DATA_UKBB_34134"

DIR_DATA_UKBB_4020457="$DIR_HOME"data/ukbb/4020457_671006_all/
mkdir -p "$DIR_DATA_UKBB_4020457"

DIR_DATA_UKBB_TABULAR_PROCESSED="$DIR_HOME"data/ukbb/tabular_processed/
mkdir -p "$DIR_DATA_UKBB_TABULAR_PROCESSED"

DIR_DATA_UKBB_GENOTYPE="$DIR_HOME"data/ukbb/4020457_671006_all/genotype/
mkdir -p "$DIR_DATA_UKBB_GENOTYPE"

DIR_DATA_UKBB_GENOTYPE_RAW="$DIR_HOME"data/ukbb/4020457_671006_all/genotype/raw/
mkdir -p "$DIR_DATA_UKBB_GENOTYPE_RAW"
DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN="$DIR_HOME"data/ukbb/4020457_671006_all/genotype/raw/22828_imp_gen/
mkdir -p "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"
DIR_DATA_UKBB_GENOTYPE_PGEN="$DIR_HOME"data/ukbb/4020457_671006_all/genotype/processed/22828_imp_gen_pgen/
mkdir -p "$DIR_DATA_UKBB_GENOTYPE_PGEN"
DIR_DATA_UKBB_GENOTYPE_BED="$DIR_HOME"data/ukbb/4020457_671006_all/genotype/processed/22828_imp_gen_bed/
mkdir -p "$DIR_DATA_UKBB_GENOTYPE_BED"

DIR_DATA_ACCEL="$DIR_HOME"data/accel/
mkdir -p "$DIR_DATA_ACCEL"

DIR_DATA_DBSNP="$DIR_HOME"data/dbsnp/
mkdir -p "$DIR_DATA_DBSNP"
DIR_DATA_DBSNP_25="$DIR_HOME"data/dbsnp/25/
mkdir -p "$DIR_DATA_DBSNP_25"
DIR_DATA_DBSNP_25_CHR="$DIR_HOME"data/dbsnp/25/per_chromosome/
mkdir -p "$DIR_DATA_DBSNP_25_CHR"
DIR_DATA_DBSNP_25_SPLIT="$DIR_HOME"data/dbsnp/25/split/
mkdir -p "$DIR_DATA_DBSNP_25_SPLIT"
DIR_DATA_DBSNP_25_RSID="$DIR_HOME"data/dbsnp/25/rsid/
mkdir -p "$DIR_DATA_DBSNP_25_RSID"

DIR_DATA_PANUKBB="$DIR_HOME"data/panukbb/
mkdir -p "$DIR_DATA_PANUKBB"
DIR_DATA_PANUKBB_MANIFEST="$DIR_HOME"data/panukbb/manifest/
mkdir -p "$DIR_DATA_PANUKBB_MANIFEST"
DIR_DATA_PANUKBB_RAW="$DIR_HOME"data/panukbb/raw/
mkdir -p "$DIR_DATA_PANUKBB_RAW"
DIR_DATA_PANUKBB_EXTRACTED="$DIR_HOME"data/panukbb/extracted/
mkdir -p "$DIR_DATA_PANUKBB_EXTRACTED"
DIR_DATA_PANUKBB_MAGMA="$DIR_HOME"data/panukbb/for_magma/
mkdir -p "$DIR_DATA_PANUKBB_MAGMA"
DIR_DATA_PANUKBB_MAGMA_PERPHENO="$DIR_HOME"data/panukbb/for_magma/per_phenotype/
mkdir -p "$DIR_DATA_PANUKBB_MAGMA_PERPHENO"

DIR_DATA_ACCEL_UKBB="$DIR_HOME"data/accel_ukbb/
mkdir -p "$DIR_DATA_ACCEL_UKBB"
DIR_DATA_ACCEL_UKBB_SPLIT="$DIR_HOME"data/accel_ukbb/split/
mkdir -p "$DIR_DATA_ACCEL_UKBB_SPLIT"
DIR_DATA_ACCEL_UKBB_WHITE="$DIR_HOME"data/accel_ukbb/white_british/
mkdir -p "$DIR_DATA_ACCEL_UKBB_WHITE"

DIR_MAGMA="$DIR_HOME"data/magma/
mkdir -p "$DIR_MAGMA"

# Codes

DIR_CODE_PREP="$DIR_HOME"code/prep/
mkdir -p "$DIR_CODE_PREP"
DIR_CODE_ANALYSIS="$DIR_HOME"code/analysis/
mkdir -p "$DIR_CODE_ANALYSIS"


# Analysis results
DIR_ANALYSIS_PANUKBB_MAGMA="$DIR_HOME"analysis/panukbb_magma/
mkdir -p "$DIR_ANALYSIS_PANUKBB_MAGMA"


#####################
# Other environment variables
#####################

N_PARALLEL=100 # Parallel cores (Depending on your environment)



#####################
# PATH
#####################

export PATH="$PATH":"$DIR_HOME""software/magma"
export PATH="$PATH":"$DIR_HOME""software/plink2"

#!bin/sh -u
set -e

#####################
# From UKBB .pgen/.psam/.pvar files,
# 	extract only the part for White-British population
#####################


source code/load_directory_tree.sh


#####################
# Extract White-British
#####################

echo ""
echo $(date)
echo "Extract White British population..."
echo ""

# Extract White British
plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"merged \
--keep "$DIR_DATA_ACCEL_UKBB_WHITE"id.txt \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british

echo ""
echo $(date)
echo "Thin for later practice..."
echo ""

# Thinning for later practices - 10000 people x 10000 variants
plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british \
--thin-indiv-count 10000 \
--thin-count 10000 \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british_thinned_1 &

# Thinning for later practices - 1000 people x all variants
plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british \
--thin-indiv-count 1000 \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british_thinned_2 &

wait


#####################
# Calculate allele frequency
#####################

# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british" \
--freq \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.freq"


#####################
# Convert to .bed
#####################

echo ""
echo $(date)
echo "Convert from .pgen/.pvar/.psam to .bed/.bim/.fam"
echo ""

plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british \
--make-bed \
--out "$DIR_DATA_UKBB_GENOTYPE_BED"white_british

echo ""
echo $(date)
echo "Thin for later practice..."
echo ""

plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british_thinned_1 \
--make-bed \
--out "$DIR_DATA_UKBB_GENOTYPE_BED"white_british_thinned_1 &

plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"white_british_thinned_2 \
--make-bed \
--out "$DIR_DATA_UKBB_GENOTYPE_BED"white_british_thinned_2 &

wait


#####################
# LD pruning
#####################

echo ""
echo $(date)
echo "Conduct LD pruning..."
echo ""

# PLINK2 usage: --indep-pairwise <window size>['kb'] [step size (variant ct)] <unphased-hardcall-r^2 threshold>
# Pan-UKBB: window size = 1000 (1 Mbp)
plink2 \
--indep-pairwise 1000kb 1 0.5 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british" \
--read-freq "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.freq.afreq" \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruning"

echo ""
echo $(date)
echo "Extract the LD-pruned fraction..."
echo ""

# Extract the LD-pruned fraction
plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british" \
--read-freq "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.freq.afreq" \
--extract "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruning.prune.in" \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruned"

echo ""
echo $(date)
echo "Re-calculate the allele frequency..."
echo ""

# Re-calculate the allele frequency
# Source location
# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruned" \
--freq \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruned.freq"


#####################
# Calculate PC (principal components)
#####################

echo ""
echo $(date)
echo "Calculate PC (principal components) using the pruned population..."
echo ""

# approx: random algorithm is necessary when handling large datasets
plink2 \
--pca allele-wts 30 approx \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruned" \
--read-freq "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.LDpruned.freq.afreq" \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""white_british.pca"


echo ""
echo $(date)
echo "Done."
echo ""
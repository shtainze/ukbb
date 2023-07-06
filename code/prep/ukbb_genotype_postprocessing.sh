#!bin/sh -u
set -e

#####################
# Process UKBB genotype data (bulk)
#####################

DIR_PFILE=$1
SUFFIX=$2


#####################
# Thinning for later practices
#####################

echo ""
echo $(date) "Thin for later practices"
echo ""

# Thinning for later practices - 10000 people x 10000 variants
plink2 \
--make-pgen \
--pfile "$DIR_PFILE""$SUFFIX" \
--thin-indiv-count 10000 \
--thin-count 10000 \
--out "$DIR_PFILE""$SUFFIX""_thinned_1" &

# Thinning for later practices - 1000 people x all variants
plink2 \
--make-pgen \
--pfile "$DIR_PFILE""$SUFFIX" \
--thin-indiv-count 1000 \
--out "$DIR_PFILE""$SUFFIX""_thinned_2" &


#####################
# Calculate allele frequency
#####################

echo ""
echo $(date) "Calculate allele frequency"
echo ""

# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_PFILE""$SUFFIX" \
--freq \
--out "$DIR_PFILE""$SUFFIX"".freq"


#####################
# Convert to .bed
#####################

echo ""
echo $(date) "Convert from .pgen/.pvar/.psam to .bed/.bim/.fam"
echo ""

plink2 \
--pfile "$DIR_PFILE""$SUFFIX" \
--make-bed \
--out "$DIR_PFILE""$SUFFIX"".bed" &

plink2 \
--pfile "$DIR_PFILE""$SUFFIX""_thinned_1" \
--make-bed \
--out "$DIR_PFILE""$SUFFIX""_thinned_1"".bed" &

plink2 \
--pfile "$DIR_PFILE""$SUFFIX""_thinned_2" \
--make-bed \
--out "$DIR_PFILE""$SUFFIX""_thinned_2"".bed" &

wait


#####################
# LD pruning
#####################

echo ""
echo $(date) "Conduct LD pruning"
echo ""

# PLINK2 usage: --indep-pairwise <window size>['kb'] [step size (variant ct)] <unphased-hardcall-r^2 threshold>
# Pan-UKBB: window size = 1000 (1 Mbp)
plink2 \
--indep-pairwise 1000kb 1 0.5 \
--pfile "$DIR_PFILE""$SUFFIX" \
--geno --mind --maf --mach-r2-filter --remove-nosex \
--read-freq "$DIR_PFILE""$SUFFIX"".freq.afreq" \
--out "$DIR_PFILE""$SUFFIX"".LDpruning"

echo ""
echo $(date) "Extract the LD-pruned fraction"
echo ""

# Extract the LD-pruned fraction
plink2 \
--make-pgen \
--pfile "$DIR_PFILE""$SUFFIX" \
--read-freq "$DIR_PFILE""$SUFFIX"".freq.afreq" \
--extract "$DIR_PFILE""$SUFFIX"".LDpruning.prune.in" \
--out "$DIR_PFILE""$SUFFIX"".LDpruned"

echo ""
echo $(date) "Re-calculate the allele frequency"
echo ""

# Re-calculate the allele frequency
# Source location
# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_PFILE""$SUFFIX"".LDpruned" \
--freq \
--out "$DIR_PFILE""$SUFFIX"".LDpruned.freq"


#####################
# Calculate PC (principal components)
#####################

echo ""
echo $(date) "Calculate PC (principal components) using the pruned population"
echo ""

# approx: random algorithm is necessary when handling large datasets
plink2 \
--pca allele-wts 30 approx \
--pfile "$DIR_PFILE""$SUFFIX"".LDpruned" \
--read-freq "$DIR_PFILE""$SUFFIX"".LDpruned.freq" \
--out "$DIR_PFILE""$SUFFIX"".pca"


echo ""
echo $(date) "Done."
echo ""
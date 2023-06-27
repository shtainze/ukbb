#!bin/sh -u
set -e

#####################
# Download & process UKBB genotype data (bulk)
#####################


source code/load_directory_tree.sh

DIR_EACH_CHR="$DIR_DATA_UKBB_GENOTYPE_2""per_chromosome/"
mkdir -p "$DIR_EACH_CHR"

DIR_MERGED_ALL="$DIR_DATA_UKBB_GENOTYPE_2""merged_all/"
mkdir -p "$DIR_MERGED_ALL"

DIR_MERGED_PANUKBB="$DIR_DATA_UKBB_GENOTYPE_2""merged_panukbb_like/"
mkdir -p "$DIR_MERGED_PANUKBB"

DIR_WHITE="$DIR_DATA_UKBB_GENOTYPE_2""white_british/"
mkdir -p "$DIR_WHITE"

# #####################
# # Convert from .bgen to .pgen
# # This is absolutely necessary for PLINK2.
# # PLINK can "directly" accept .bgen inputs,
# #	but in reality, it first converts them to .pgen files.
# # 	The conversion beforehand will greatly save time.
# #####################

# echo ""
# echo $(date) "Convert from .bgen to .pgen"
# echo "Iteration will continue until all calculation finishes without error"

# # Make a text file to specify and exclude “missing ID” variants.
# # It’s content is actually only a single period character, 
# #	which corresponds to missing ID produced by the "missing" flag.
# echo "." > "$DIR_DATA_UKBB_GENOTYPE_2"exclude.txt


# # A flag to record that the previous calculation was incomplete
# function check_previous_incomplete() {
#   file_1=$1
#   file_2=$2
#   if (! test -e "$file_1" && test -e "$file_2" ); then
#     echo "A proper set of output files was found" 1>&2
#     result=0
#   else
#   	echo "A proper set of output files was not found" 1>&2
#     result=1
#   fi
#   echo "$result"
# }


# # A flag to record that the previous calculation ended with an error
# function check_log() {
#   file_log="$1"
#   result=0
#   if [ -f "$file_log" ]; then
#     # Flag if there's an error
#     if grep -q "Error" "$file_log"; then
#       echo "Error found in the log file" 1>&2
#       result=1
#     fi
#     # Flag if the file is too small (= incomplete calculation)
#     file_size=$(wc -c < "$file_log")
#     if [ "$file_size" -lt 1000 ]; then
#     	echo "Incomplete log file" 1>&2
#     	result=1
#     fi
#   else
#   	# Flag if the log is nonexistent
#   	echo "Log file does not exist" 1>&2
#     result=1
#   fi
#   echo "$result"
# }


# # inside the command:
# # --set-all-var-ids
# # 	fill in empty accession numbers
# #	"@:#[b37]\$r,\$a" (concatenate chr,pos,ref,alt)
# #	for unambiguous expression
# # --new-id-max-allele-len 100 missing
# #	cut very long names
# # --oxford-single-chr
# #	 explicitly give the chromosome number
# # --geno --mind --maf --mach-r2-filter --remove-nosex
# #	Quality control (QC) = filtering
# # 	--geno filters out all variants with missing call rates
# #		exceeding the provided value (default 0.1)
# # 	--mind does the same for samples
# # 	--maf filters out all variants with allele frequency
# #		below the provided threshold (default 0.01)"
# # 	--mach-r2-filter excludes variants where the MaCH Rsq
# #		imputation quality metric (frequently labeled as 'INFO')
# #		is outside [0.1, 2.0]”
# # 	--remove-nosex excludes unknown-sex samples
# function single(){
# 	# A flag to record that PLINK2 is executed at least once
#     flag_exec=0

#     # A flag to record that the previous calculation was incomplete
#     flag_previous_complete=0

#     # A flag to record that the previous calculation ended with an error
#     flag_previous_error=0

# 	# Autosomal chromosomes
# 	for i in `seq 1 22`
# 	do
# 		echo "" 1>&2
# 		echo "Start processing chromosome" "$i" 1>&2

# 		str_command=\
# "plink2 --make-pgen --bgen "\
# "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"\
# "ukb22828_c"\
# "$i"\
# "_b0_v3.bgen ref-first --set-all-var-ids @:#[b37]\\\$r,\\\$a"\
# " --new-id-max-allele-len 100 missing"\
# " --sample ""$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_c1_b0_v3_s487163.sample"\
# " --keep ""$DIR_DATA_ACCEL_UKBB_WHITE""id.txt"\
# " --oxford-single-chr ""$i"\
# " --remove-nosex"\
# " --rm-dup --exclude ""$DIR_DATA_UKBB_GENOTYPE_2""exclude.txt"\
# " --out ""$DIR_EACH_CHR""chr""$i"

# 		# Check if the previous calculation was done
# 		# 	= there's "$file_final" and not "$file_intermediate"
# 		file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
# 		file_final="$DIR_EACH_CHR""chr""$i"".pgen"
# 		flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

# 		# Check if the previous calculation ended with an error
# 	    file_log="$DIR_EACH_CHR""chr""$i"".log"
# 	    flag_previous_error=($(check_log "$file_log"))

# 	    # Do the calculation if the previous calculation was not complete
# 		if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
# 			echo "Skip because the calculation is complete" 1>&2
# 		else
# 			flag_exec=1
# 			echo "Proceed to (re-)calculation" 1>&2
# 			eval $str_command 1>&2 &
# 		fi
# 		sleep 1
# 	done

# 	# The .bgen file for ChrX and ChrXY can’t be
# 	# 	converted to .pgen in the same way as 
# 	# 	for autosomal chromosomes since the 
# 	#	participant number is different.
# 	#	Therefore, separate .sample files are necessary.

# 	# Chr X
# 	echo "" 1>&2
# 	echo "Start processing chromosome X" 1>&2
# 	i="X"
# 	# Check if the previous calculation was done
# 	# 	= there's "$file_final" and not "$file_intermediate"
# 	file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
# 	file_final="$DIR_EACH_CHR""chr""$i"".pgen"
# 	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

# 	# Check if the previous calculation ended with an error
#     file_log="$DIR_EACH_CHR""chr""$i"".log"
#     flag_previous_error=($(check_log "$file_log"))

#     # Do the calculation if the previous calculation was not complete
# 	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
# 		echo "Skip because the calculation is complete" 1>&2
# 	else
# 		flag_exec=1
# 		echo "Proceed to (re-)calculation" 1>&2
# 		plink2 --make-pgen \
# 		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cX_b0_v3.bgen" ref-first \
# 		--set-all-var-ids @:#[b37]\$r,\$a \
# 		--new-id-max-allele-len 100 missing \
# 		--sample "$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_cX_b0_v3_s486512.sample" \
# 		--keep "$DIR_DATA_ACCEL_UKBB_WHITE""id.txt" \
# 		--oxford-single-chr X \
# 		--remove-nosex \
# 		--rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_2""exclude.txt" \
# 		--out "$DIR_EACH_CHR""chrX" 1>&2 &
# 	fi
# 	sleep 1

# 	# Chr XY
# 	echo "" 1>&2
# 	echo "Start processing chromosome XY" 1>&2
# 	i="XY"
# 	# Check if the previous calculation was done
# 	# 	= there's "$file_final" and not "$file_intermediate"
# 	file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
# 	file_final="$DIR_EACH_CHR""chr""$i"".pgen"
# 	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

# 	# Check if the previous calculation ended with an error
#     file_log="$DIR_EACH_CHR""chr""$i"".log"
#     flag_previous_error=($(check_log "$file_log"))

#     # Do the calculation if the previous calculation was not complete
# 	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
# 		echo "Skip because the calculation is complete" 1>&2
# 	else
# 		flag_exec=1
# 		echo "Proceed to (re-)calculation" 1>&2
# 		plink2 --make-pgen \
# 		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cXY_b0_v3.bgen" ref-first \
# 		--set-all-var-ids @:#[b37]\$r,\$a \
# 		--new-id-max-allele-len 100 missing \
# 		--sample "$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_cXY_b0_v3_s486198.sample" \
# 		--keep "$DIR_DATA_ACCEL_UKBB_WHITE""id.txt" \
# 		--oxford-single-chr XY \
# 		--remove-nosex \
# 		--rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_2""exclude.txt" \
# 		--out "$DIR_EACH_CHR""chrXY" 1>&2 &
# 	fi

# 	wait
# 	# Stands as a return value
# 	echo "$flag_exec"
# }

# N_ITER=1
# FLAG_EXEC=1
# while [ "$FLAG_EXEC" -eq 1 ]
# do
#   echo ""
#   echo $(date)
#   echo "Iteration" "$N_ITER"
#   FLAG_EXEC=($(single))
#   N_ITER=`expr $N_ITER + 1`
#   sleep 1
# done


# # ####################
# # Merge .pgen files
# # 	To conduct GWAS in PLINK2, genotype information
# # 	should be stored in a single file.
# # ####################


# echo ""
# echo $(date) "Merge .pgen files"
# echo ""

# # Make a list of files to be merged
# echo "$DIR_EACH_CHR""chr1" > "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr2" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr3" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr4" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr5" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr6" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr7" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr8" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr9" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr10" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr11" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr12" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr13" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr14" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr15" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr16" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr17" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr18" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr19" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr20" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr21" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chr22" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"
# echo "$DIR_EACH_CHR""chrXY" >> "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt"

# # Merge
# plink2 \
# --make-pgen \
# --pmerge-list "$DIR_DATA_UKBB_GENOTYPE_2""mergelist.txt" \
# --merge-max-allele-ct 2 \
# --remove-nosex \
# --rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_2""exclude.txt" \
# --out "$DIR_MERGED_ALL""merged"


# #####################
# # Thinning for later practices
# #####################


# plink2 \
# --make-pgen \
# --pfile "$DIR_MERGED_ALL""merged" \
# --thin-indiv-count 10000 \
# --thin-count 10000 \
# --out "$DIR_MERGED_ALL""thinned"


# #####################
# # Calculate allele frequency
# #####################

# # Create a .afreq file in the same location
# plink2 \
# --pfile "$DIR_MERGED_ALL""merged" \
# --freq \
# --out "$DIR_MERGED_ALL""merged.freq"


# #####################
# # Extract PanUKBB-listed SNPs
# #####################

# plink2 \
# --make-pgen \
# --pfile "$DIR_MERGED_ALL""merged" \
# --extract "$DIR_DATA_PANUKBB_MAGMA""snp_id_only.txt" \
# --merge-max-allele-ct 2 \
# --remove-nosex \
# --rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_2""exclude.txt" \
# --out "$DIR_MERGED_PANUKBB""merged"


# #####################
# # Calculate allele frequency
# #####################

# # Create a .afreq file in the same location
# plink2 \
# --pfile "$DIR_MERGED_PANUKBB""merged" \
# --freq \
# --out "$DIR_MERGED_PANUKBB""merged.freq"


#####################
# Extract White British
#####################

# echo ""
# echo $(date) "Extract White British population"
# echo ""

# plink2 \
# --make-pgen \
# --pfile "$DIR_MERGED_PANUKBB""merged" \
# --keep "$DIR_DATA_ACCEL_UKBB_WHITE""id.txt" \
# --out "$DIR_WHITE""white_british"

# echo ""
# echo $(date) "Thin for later practice"
# echo ""

# # Thinning for later practices - 10000 people x 10000 variants
# plink2 \
# --make-pgen \
# --pfile "$DIR_WHITE""white_british" \
# --thin-indiv-count 10000 \
# --thin-count 10000 \
# --out "$DIR_WHITE""white_british_thinned_1" &

# # Thinning for later practices - 1000 people x all variants
# plink2 \
# --make-pgen \
# --pfile "$DIR_WHITE""white_british" \
# --thin-indiv-count 1000 \
# --out "$DIR_WHITE""white_british_thinned_2" &

# wait


# #####################
# # Calculate allele frequency
# #####################

# echo ""
# echo $(date) "Calculate allele frequency"
# echo ""

# # Create a .afreq file in the same location
# plink2 \
# --pfile "$DIR_WHITE""white_british" \
# --freq \
# --out "$DIR_WHITE""white_british.freq"


# #####################
# # Convert to .bed
# #####################

# echo ""
# echo $(date) "Convert from .pgen/.pvar/.psam to .bed/.bim/.fam"
# echo ""

# plink2 \
# --pfile "$DIR_WHITE""white_british" \
# --make-bed \
# --out "$DIR_WHITE""white_british.bed" &

# plink2 \
# --pfile "$DIR_WHITE""white_british_thinned_1" \
# --make-bed \
# --out "$DIR_WHITE""white_british_thinned_1.bed" &

# plink2 \
# --pfile "$DIR_WHITE""white_british_thinned_2" \
# --make-bed \
# --out "$DIR_WHITE""white_british_thinned_2.bed" &

# wait


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
--pfile "$DIR_WHITE""white_british" \
--geno --mind --maf --mach-r2-filter --remove-nosex \
--read-freq "$DIR_WHITE""white_british.freq.afreq" \
--out "$DIR_WHITE""white_british.LDpruning"

echo ""
echo $(date) "Extract the LD-pruned fraction"
echo ""

# Extract the LD-pruned fraction
plink2 \
--make-pgen \
--pfile "$DIR_WHITE""white_british" \
--read-freq "$DIR_WHITE""white_british.freq.afreq" \
--extract "$DIR_WHITE""white_british.LDpruning.prune.in" \
--out "$DIR_WHITE""white_british.LDpruned"

echo ""
echo $(date) "Re-calculate the allele frequency"
echo ""

# Re-calculate the allele frequency
# Source location
# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_WHITE""white_british.LDpruned" \
--freq \
--out "$DIR_WHITE""white_british.LDpruned.freq"


#####################
# Calculate PC (principal components)
#####################

echo ""
echo $(date) "Calculate PC (principal components) using the pruned population"
echo ""

# approx: random algorithm is necessary when handling large datasets
plink2 \
--pca allele-wts 30 approx \
--pfile "$DIR_WHITE""white_british.LDpruned" \
--read-freq "$DIR_WHITE""white_british.LDpruned.freq.afreq" \
--out "$DIR_WHITE""white_british.pca"


echo ""
echo $(date)
echo "Done."
echo ""














echo ""
echo $(date)
echo "Done."
echo ""
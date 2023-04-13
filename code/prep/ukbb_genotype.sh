#!bin/sh -u
set -e

#####################
# Download & process UKBB genotype data (bulk)
#####################


source code/load_directory_tree.sh


#####################
# Download
#####################

echo ""
echo $(date)
echo "Start downloading UKBB genotype data..."
echo "Output folder:" "$DIR_DATA_UKBB_4020457"

# FAM file (chromosome number is required but does not matter)
echo ""
echo $(date)
echo "Downloading the .fam file..."
cd "$DIR_DATA_UKBB_4020457"
rm -f ukb22418_c1_b0_v2_s488131.fam
"$DIR_SOFTWARE_UKBB"gfetch \
22418 -c1 -m \
-ak62001r671006.key
chmod 777 ./ukb22418_c1_b0_v2_s488131.fam
mv ./ukb22418_c1_b0_v2_s488131.fam "$DIR_DATA_UKBB_GENOTYPE_RAW"

# Genotype call
echo ""
echo $(date)
echo "Downloading the .bed file..."
cd "$DIR_DATA_UKBB_4020457"
"$DIR_SOFTWARE_UKBB"gfetch 22418 -c1 -ak62001r671006.key
mv ./ukb22418_c1_b0_v2.bed "$DIR_DATA_UKBB_GENOTYPE_RAW"


# Imputation sample (chromosome number is required but does not matter)
# Available for autosomes, chrX and chrXY.
echo ""
echo $(date)
echo "Downloading the imputation samples..."
cd "$DIR_DATA_UKBB_4020457"
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c1 -m -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -cX -m -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -cXY -m -ak62001r671006.key &
wait
mv ./ukb22828_*.sample "$DIR_DATA_UKBB_GENOTYPE_RAW"


# Imputation BGEN (the largest files)
echo ""
echo $(date)
echo "Downloading the imputation samples..."
cd "$DIR_DATA_UKBB_4020457"
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c1 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c2 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c3 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c4 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c5 -ak62001r671006.key &
wait
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c6 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c7 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c8 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c9 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c10 -ak62001r671006.key &
wait
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c11 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c12 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c13 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c14 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c15 -ak62001r671006.key &
wait
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c16 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c17 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c18 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c19 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c20 -ak62001r671006.key &
wait
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c21 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -c22 -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -cX -ak62001r671006.key &
"$DIR_SOFTWARE_UKBB"gfetch 22828 -cXY -ak62001r671006.key &
wait

mv ./ukb22828_*.bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"


#####################
# Convert from .bgen to .pgen
# This is absolutely necessary for PLINK2.
# PLINK can “directly” accept .bgen inputs,
#	but in reality, it first converts them to .pgen files.
# 	The conversion beforehand will greatly save time.
#####################

echo ""
echo $(date)
echo "Convert from .bgen to .pgen..."
echo "Iteration will continue until all calculation finishes without error"

# Make a text file to specify and exclude “missing ID” variants.
# It’s content is actually only a single period character, 
#	which corresponds to missing ID produced by the "missing" flag.
echo "." > "$DIR_DATA_UKBB_GENOTYPE_PGEN"exclude.txt


# A flag to record that the previous calculation was incomplete
function check_previous_incomplete() {
  file_1=$1
  file_2=$2
  if (! test -e "$file_1" && test -e "$file_2" ); then
    echo "A proper set of output files was found" 1>&2
    result=0
  else
  	echo "A proper set of output files was not found" 1>&2
    result=1
  fi
  echo "$result"
}


# A flag to record that the previous calculation ended with an error
function check_log() {
  file_log="$1"
  result=0
  if [ -f "$file_log" ]; then
    # Flag if there's an error
    if grep -q "Error" "$file_log"; then
      echo "Error found in the log file" 1>&2
      result=1
    fi
    # Flag if the file is too small (= incomplete calculation)
    file_size=$(wc -c < "$file_log")
    if [ "$file_size" -lt 1000 ]; then
    	echo "Incomplete log file" 1>&2
    	result=1
    fi
  else
  	# Flag if the log is nonexistent
  	echo "Log file does not exist" 1>&2
    result=1
  fi
  echo "$result"
}


# inside the command:
# --set-all-var-ids
# 	fill in empty accession numbers
#	"@:#[b37]\$r,\$a" (concatenate chr,pos,ref,alt)
#	for unambiguous expression
# --new-id-max-allele-len 100 missing
#	cut very long names
# --oxford-single-chr
#	 explicitly give the chromosome number
# --geno --mind --maf --mach-r2-filter --remove-nosex
#	Quality control (QC) = filtering
# 	--geno filters out all variants with missing call rates
#		exceeding the provided value (default 0.1)
# 	--mind does the same for samples
# 	--maf filters out all variants with allele frequency
#		below the provided threshold (default 0.01)"
# 	--mach-r2-filter excludes variants where the MaCH Rsq
#		imputation quality metric (frequently labeled as 'INFO')
#		is outside [0.1, 2.0]”
# 	--remove-nosex excludes unknown-sex samples
function single(){
	# A flag to record that PLINK2 is executed at least once
    flag_exec=0

    # A flag to record that the previous calculation was incomplete
    flag_previous_complete=0

    # A flag to record that the previous calculation ended with an error
    flag_previous_error=0

	# Autosomal chromosomes
	for i in `seq 1 22`
	do
		echo "" 1>&2
		echo "Start processing chromosome" "$i" 1>&2

		str_command=\
"plink2 --make-pgen --bgen "\
"$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"\
"ukb22828_c"\
"$i"\
"_b0_v3.bgen ref-first --set-all-var-ids @:#[b37]\\\$r,\\\$a"\
" --new-id-max-allele-len 100 missing"\
" --sample ""$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_c1_b0_v3_s487163.sample"\
" --oxford-single-chr ""$i"\
" --geno --mind --maf --mach-r2-filter --remove-nosex"\
" --rm-dup --exclude ""$DIR_DATA_UKBB_GENOTYPE_PGEN""exclude.txt"\
" --out ""$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"

		# Check if the previous calculation was done
		# 	= there's "$file_final" and not "$file_intermediate"
		file_intermediate="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i""-temporary.pgen"
		file_final="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".pgen"
		flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

		# Check if the previous calculation ended with an error
	    file_log="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".log"
	    flag_previous_error=($(check_log "$file_log"))

	    # Do the calculation if the previous calculation was not complete
		if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
			echo "Skip because the calculation is complete" 1>&2
		else
			flag_exec=1
			echo "Proceed to (re-)calculation" 1>&2
			eval $str_command 1>&2 &
		fi
		sleep 1
	done

	# The .bgen file for ChrX and ChrXY can’t be
	# 	converted to .pgen in the same way as 
	# 	for autosomal chromosomes since the 
	#	participant number is different.
	#	Therefore, separate .sample files are necessary.

	# Chr X
	echo "" 1>&2
	echo "Start processing chromosome X" 1>&2
	i="X"
	# Check if the previous calculation was done
	# 	= there's "$file_final" and not "$file_intermediate"
	file_intermediate="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i""-temporary.pgen"
	file_final="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".pgen"
	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

	# Check if the previous calculation ended with an error
    file_log="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".log"
    flag_previous_error=($(check_log "$file_log"))

    # Do the calculation if the previous calculation was not complete
	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
		echo "Skip because the calculation is complete" 1>&2
	else
		flag_exec=1
		echo "Proceed to (re-)calculation" 1>&2
		plink2 --make-pgen \
		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cX_b0_v3.bgen" ref-first \
		--set-all-var-ids @:#[b37]\$r,\$a \
		--new-id-max-allele-len 100 missing \
		--sample "$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_cX_b0_v3_s486512.sample" \
		--oxford-single-chr X \
		--geno --mind --maf --mach-r2-filter --remove-nosex \
		--rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_PGEN""exclude.txt" \
		--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""chrX" 1>&2 &
	fi
	sleep 1

	# Chr XY
	echo "" 1>&2
	echo "Start processing chromosome XY" 1>&2
	i="XY"
	# Check if the previous calculation was done
	# 	= there's "$file_final" and not "$file_intermediate"
	file_intermediate="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i""-temporary.pgen"
	file_final="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".pgen"
	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

	# Check if the previous calculation ended with an error
    file_log="$DIR_DATA_UKBB_GENOTYPE_PGEN""chr""$i"".log"
    flag_previous_error=($(check_log "$file_log"))

    # Do the calculation if the previous calculation was not complete
	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
		echo "Skip because the calculation is complete" 1>&2
	else
		flag_exec=1
		echo "Proceed to (re-)calculation" 1>&2
		plink2 --make-pgen \
		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cXY_b0_v3.bgen" ref-first \
		--set-all-var-ids @:#[b37]\$r,\$a \
		--new-id-max-allele-len 100 missing \
		--sample "$DIR_DATA_UKBB_GENOTYPE_RAW""ukb22828_cXY_b0_v3_s486198.sample" \
		--oxford-single-chr XY \
		--geno --mind --maf --mach-r2-filter --remove-nosex \
		--rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_PGEN""exclude.txt" \
		--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""chrXY" 1>&2 &
	fi

	wait
	# Stands as a return value
	echo "$flag_exec"
}

N_ITER=1
FLAG_EXEC=1
while [ "$FLAG_EXEC" -eq 1 ]
do
  echo ""
  echo $(date)
  echo "Iteration" "$N_ITER"
  FLAG_EXEC=($(single))
  N_ITER=`expr $N_ITER + 1`
  sleep 1
done


# ####################
# Merge .pgen files
# 	To conduct GWAS in PLINK2, genotype information
# 	should be stored in a single file.
# ####################


echo ""
echo $(date)
echo "Merge .pgen files..."
echo ""

# Make a list of files to be merged
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr1" > "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr2" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr3" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr4" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr5" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr6" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr7" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr8" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr9" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr10" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr11" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr12" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr13" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr14" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr15" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr16" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr17" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr18" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr19" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr20" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr21" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chr22" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt
echo "$DIR_DATA_UKBB_GENOTYPE_PGEN""chrXY" >> "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt

# Merge
plink2 \
--make-pgen \
--pmerge-list "$DIR_DATA_UKBB_GENOTYPE_PGEN"mergelist.txt \
--merge-max-allele-ct 2 \
--geno --mind --maf --mach-r2-filter --remove-nosex \
--rm-dup --exclude "$DIR_DATA_UKBB_GENOTYPE_PGEN""exclude.txt" \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"merged


#####################
# Thinning for later practices
#####################


plink2 \
--make-pgen \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"merged \
--thin-indiv-count 10000 \
--thin-count 10000 \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"thinned


#####################
# Calculate allele frequency
#####################

# Create a .afreq file in the same location
plink2 \
--pfile "$DIR_DATA_UKBB_GENOTYPE_PGEN"merged \
--freq \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN"merged.freq


echo ""
echo $(date)
echo "Done."
echo ""
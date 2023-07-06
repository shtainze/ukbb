#!bin/sh -u
set -e

#####################
# Convert from .bgen to .pgen
# Merge them all without filtering
#####################

DIR_DATA_UKBB_GENOTYPE_RAW=$1
DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN=$2
DIR_DATA_UKBB_GENOTYPE_PGEN=$3
DIR_DATA_ACCEL_UKBB_WHITE=$4

DIR_EACH_CHR="$DIR_DATA_UKBB_GENOTYPE_PGEN""per_chromosome/"
mkdir -p "$DIR_EACH_CHR"

# List of variants to exclude from the merge
FILE_EXCLUDE="$DIR_DATA_UKBB_GENOTYPE_PGEN"exclude.txt
# List of files to merge
FILE_MERGELIST="$DIR_DATA_UKBB_GENOTYPE_PGEN""mergelist.txt"


#####################
# Convert from .bgen to .pgen
# This is absolutely necessary for PLINK2.
# PLINK can "directly" accept .bgen inputs,
#	but in reality, it first converts them to .pgen files.
# 	The conversion beforehand will greatly save time.
#####################

echo ""
echo $(date) "Convert from .bgen to .pgen"
echo "Iteration will continue until all calculation finishes without error"

# Make a text file to specify and exclude “missing ID” variants.
# It’s content is actually only a single period character, 
#	which corresponds to missing ID produced by the "missing" flag.
echo "." > "$FILE_EXCLUDE"


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

		# Initialize a counter for the number of jobs
		job_count=0

	# Autosomal chromosomes
	for i in `seq 1 22`
	do
		echo "" 1>&2
		echo "Start processing chromosome" "$i" 1>&2
		FILE_SAMPLE=$(find "$DIR_DATA_UKBB_GENOTYPE_RAW" -name "*c1*.sample")
		str_command=\
"plink2 --make-pgen --bgen "\
"$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN"\
"ukb22828_c"\
"$i"\
"_b0_v3.bgen ref-first --set-all-var-ids @:#[b37]\\\$r,\\\$a"\
" --new-id-max-allele-len 100 missing"\
" --sample ""$FILE_SAMPLE"\
" --oxford-single-chr ""$i"\
" --remove-nosex"\
" --rm-dup --exclude ""$FILE_EXCLUDE"\
" --out ""$DIR_EACH_CHR""chr""$i"

		# Check if the previous calculation was done
		# 	= there's "$file_final" and not "$file_intermediate"
		file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
		file_final="$DIR_EACH_CHR""chr""$i"".pgen"
		flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

		# Check if the previous calculation ended with an error
	    file_log="$DIR_EACH_CHR""chr""$i"".log"
	    flag_previous_error=($(check_log "$file_log"))

	    # Do the calculation if the previous calculation was not complete
		if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
			echo "Skip because the calculation is complete" 1>&2
		else
			flag_exec=1
			echo "Proceed to (re-)calculation" 1>&2
			eval $str_command 1>&2 &
			job_count=$((job_count+1))
			sleep 10
		  # If the job count has reached 5, wait for one job to finish
		  if [ "$job_count" -ge 4 ]; then
		    wait -n
		    job_count=$((job_count-1))
		  fi			
		fi
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
	file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
	file_final="$DIR_EACH_CHR""chr""$i"".pgen"
	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

	# Check if the previous calculation ended with an error
    file_log="$DIR_EACH_CHR""chr""$i"".log"
    flag_previous_error=($(check_log "$file_log"))

    # Do the calculation if the previous calculation was not complete
	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
		echo "Skip because the calculation is complete" 1>&2
	else
		flag_exec=1
		echo "Proceed to (re-)calculation" 1>&2
		FILE_SAMPLE=$(find "$DIR_DATA_UKBB_GENOTYPE_RAW" -name "*cX_*.sample")
		plink2 --make-pgen \
		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cX_b0_v3.bgen" ref-first \
		--set-all-var-ids @:#[b37]\$r,\$a \
		--new-id-max-allele-len 100 missing \
		--sample "$FILE_SAMPLE" \
		--oxford-single-chr X \
		--remove-nosex \
		--rm-dup --exclude "$FILE_EXCLUDE" \
		--out "$DIR_EACH_CHR""chrX" 1>&2 &
	fi
	sleep 10

	# Chr XY
	echo "" 1>&2
	echo "Start processing chromosome XY" 1>&2
	i="XY"
	# Check if the previous calculation was done
	# 	= there's "$file_final" and not "$file_intermediate"
	file_intermediate="$DIR_EACH_CHR""chr""$i""-temporary.pgen"
	file_final="$DIR_EACH_CHR""chr""$i"".pgen"
	flag_previous_incomplete=($(check_previous_incomplete "$file_intermediate" "$file_final"))

	# Check if the previous calculation ended with an error
    file_log="$DIR_EACH_CHR""chr""$i"".log"
    flag_previous_error=($(check_log "$file_log"))

    # Do the calculation if the previous calculation was not complete
	if [ "$flag_previous_incomplete" -eq 0 ] && [ "$flag_previous_error" -eq 0 ]; then
		echo "Skip because the calculation is complete" 1>&2
	else
		flag_exec=1
		echo "Proceed to (re-)calculation" 1>&2
		FILE_SAMPLE=$(find "$DIR_DATA_UKBB_GENOTYPE_RAW" -name "*cXY*.sample")
		plink2 --make-pgen \
		--bgen "$DIR_DATA_UKBB_GENOTYPE_RAW_IMPGEN""ukb22828_cXY_b0_v3.bgen" ref-first \
		--set-all-var-ids @:#[b37]\$r,\$a \
		--new-id-max-allele-len 100 missing \
		--sample "$FILE_SAMPLE" \
		--oxford-single-chr XY \
		--remove-nosex \
		--rm-dup --exclude "$FILE_EXCLUDE" \
		--out "$DIR_EACH_CHR""chrXY" 1>&2 &
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
  sleep 10
done


# ####################
# Merge .pgen files
# 	To conduct GWAS in PLINK2, genotype information
# 	should be stored in a single file.
# ####################


echo ""
echo $(date) "Merge .pgen files"
echo ""

# Make a list of files to be merged
echo "$DIR_EACH_CHR""chr1" > "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr2" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr3" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr4" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr5" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr6" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr7" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr8" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr9" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr10" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr11" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr12" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr13" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr14" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr15" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr16" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr17" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr18" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr19" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr20" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr21" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chr22" >> "$FILE_MERGELIST"
echo "$DIR_EACH_CHR""chrXY" >> "$FILE_MERGELIST"

# Merge
plink2 \
--make-pgen \
--pmerge-list "$FILE_MERGELIST" \
--merge-max-allele-ct 2 \
--remove-nosex \
--rm-dup --exclude "$FILE_EXCLUDE" \
--out "$DIR_DATA_UKBB_GENOTYPE_PGEN""merged"

echo ""
echo $(date) "Done."
echo ""
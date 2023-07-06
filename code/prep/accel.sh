#!bin/sh -u
set -e

#####################
# This script formats the ACCEL dataset.
# Specifically, it converts the cluster information to
#   a more readable format for PLINK2.
# The original data is preserved as it is, and
#   the converted formats are added as the last columns.
#####################


source code/load_directory_tree_202307.sh

# Input - ACCEL data
FILE_ACCEL="$DIR_DATA_ACCEL"FEATURES_ABNORMAL_GROUP_NAME_NEW_RULE_RECORDING_INFO.txt

# Output - Formatted ACCEL data
FILE_OUT="$DIR_DATA_ACCEL"formatted.txt


echo ""
echo $(date)
echo "Formatting the ACCEL data..."

# Cut the unnecessary part
# Convert ":" to "_", as ":" causes trouble on Excel
# Convert " " to "_", as the mixture of " " and "," causes trouble on awk

HEADER=$(cat "$FILE_ACCEL" | head -n 1 | sed 's/\n//g' | sed 's/\r//g' | sed 's/ /_/g')
HEADER="$HEADER"",cluster_alphabet,group_five,group_eight,abnormal_group_eight"
HEADER=$(echo "$HEADER" | sed 's/name/eid_old/g')
echo "$HEADER" > "$FILE_OUT"

cat "$FILE_ACCEL" | tail -n +2 | awk -F "," '
    BEGIN{
        OFS = ","
    }
    {
        gsub( "_.*", "", $1 )
        gsub( ":", "_", $27 )
        print $0
    }
' | awk -F "," '        
    BEGIN{
        OFS = ","
    }
    {
        gsub( " ", "_", $0 )
        print $0
    }
' | awk -F, '        
    BEGIN{
        OFS = ","
    }
    {
    	a=$27 # Hierarchical clusters
        gsub( "1_1_0", "D", a )
        gsub( "1_1_1", "E", a )
        gsub( "2_1_0", "G", a )
        gsub( "2_1_1", "H", a )
        gsub( "2_1_2", "I", a )
        gsub( "2_1_3", "J", a )
        gsub( "2_1_4", "K", a )
        gsub( "2_1_5", "L", a )
        gsub( "2_1_6", "M", a )
        gsub( "0_0", "A", a )
        gsub( "0_1", "B", a )
        gsub( "1_0", "C", a )
        gsub( "2_0", "F", a )
        gsub( "2_2", "N", a )
        gsub( "3", "O", a )
        gsub( "4_0", "P", a )
        gsub( "4_1", "Q", a )
        gsub( "noise", "", a )
        b=$28 # 16 clusters
        gsub( "1", "A", b )
        gsub( "2a", "B", b )
        gsub( "2b", "C", b )
        gsub( "3a", "D", b )
        gsub( "3b", "E", b )
        gsub( "4a", "F", b )
        gsub( "4b", "G", b )
        gsub( "5", "H", b )
        c=$29 # 16 clusters
        gsub( "3b-1", "A", c )
        gsub( "3b-2", "B", c )
        gsub( "4b-1", "C", c )
        gsub( "4b-2", "D", c )
        gsub( "4b-3", "E", c )
        gsub( "4b-4", "F", c )
        gsub( "4b-5", "G", c )
        gsub( "4b-6", "H", c )
        print $0,a,substr($28,1,1),b,c
    }
' | sort -k1,1 -k2,2n >> "$FILE_OUT"
#

##########################

echo ""
echo $(date)
echo "Done."
echo ""

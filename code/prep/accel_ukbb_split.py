#############
# Purpose
# The UKBiobank-ACCEL dataset is too huge to handle,
#   containing 28483 columns x 502387 rows
# To ease handling, the dataset will be split
#   into 28482 files, consisting of the following two columns:
#       eid
#       one of the other 28482 columns
#############

from datetime import datetime
import sys, os

# For some unknown reason, "import pandas as pd"
#   fails at 1st attempt and succeeds at 2nd attempt
try:
    import pandas as pd
except:
    import pandas as pd

#############
# Set I/O
#############

# Input
# Assuming that the script was called from the home dirtectory
DIR_HOME = os.getcwd()
DIR_WORK = os.path.join(DIR_HOME, "data", "ukbb", "4047708_673112_all")
FILE_SOURCE_1 = os.path.join(DIR_WORK, "accel_ukbb", 
    "ukbb_accel_merged_formatted.txt")
FILE_SOURCE_2 = os.path.join(DIR_WORK, "accel_ukbb", 
    "ukbb_accel_accel_only.txt")

# Output
DIR_OUT_1 = os.path.join(DIR_WORK, "accel_ukbb", "split", "all")
if not os.path.exists(DIR_OUT_1):
    os.makedirs(DIR_OUT_1)
DIR_OUT_2 = os.path.join(DIR_WORK, "accel_ukbb", "split", "accel_only")
if not os.path.exists(DIR_OUT_2):
    os.makedirs(DIR_OUT_2)


print()
print(datetime.now(), 
    "Start splitting UKBB-ACCEL data into single columns")


#############
# Function
#############

# Split into each column
def func_split(df, l_cols, n, dir_out):
    for i in range(1, len(l_cols)):
        df_write = df[l_cols[[0,i]]]
        # Filename example: "13188_20230-0.70.txt"
        filename = '{:0=5}'.format(i) + "_" + l_cols[i] + ".txt"
        filename = os.path.join(dir_out, filename)
        if n == 0:
            df_write.to_csv(filename,
             index=False, na_rep='NA', sep='\t')
        else:
            df_write.to_csv(filename,
             index=False, na_rep='NA', sep='\t', mode='a', header=False)

def func_main(file_source, dir_out):
    print("Input:", file_source, "Output:", dir_out)
    # Read the file
    reader = pd.read_csv(file_source, 
        chunksize=50, dtype=str, delimiter='\t')
    # Get the column names
    df = reader.get_chunk(5)
    l_cols = df.columns
    print()
    print(len(l_cols), "columns are found")
    print(len(list(set(l_cols))), "of them have separate names")
    print("First 10:", l_cols[0:10])
    # Main processing
    print(datetime.now(), "Start splitting into two-column files")
    # Re-initialize
    reader = pd.read_csv(file_source, 
        chunksize=5000, dtype=str, delimiter='\t')
    # Process all
    print("Processing file No:")
    n = 0
    for r in reader:
        print(datetime.now(), n)
        func_split(r, l_cols, n, dir_out)
        n += 1
    print()
    print(datetime.now())
    print("Done.")


# func_main(FILE_SOURCE_1, DIR_OUT_1)
# func_main(FILE_SOURCE_2, DIR_OUT_2)



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
FILE_SOURCE = os.path.join(DIR_HOME, "data", "accel_ukbb", 
    "ukbb671006_accel_merged_formatted.txt")

# Output
DIR_OUT = os.path.join(DIR_HOME, "data", "accel_ukbb", "split")

# Chunk size (corresponding to the number of individuals) to be read at once
chunk_size = 5000

print()
print(datetime.now(), 
    "Start splitting UKBB-ACCEL data into single columns")


#############
# Prepare
#############

# Read the file
reader = pd.read_csv(FILE_SOURCE, chunksize=50, dtype=str, delimiter='\t')
# Get the column names
df = reader.get_chunk(5)
l_cols = df.columns
print()
print(len(l_cols), "columns are found")
print(len(list(set(l_cols))), "of them have separate names")
print("First 10:", l_cols[0:10])


#############
# Process
#############

# Split into each column
def func_split(df, l_cols, n):
    for i in range(1, len(l_cols)):
        df_write = df[l_cols[[0,i]]]
        filename = "ukb671006_" + '{:0=5}'.format(i) + "_" + l_cols[i] + ".txt"
        filename = os.path.join(DIR_OUT, filename)
        if n == 0:
            df_write.to_csv(filename,
             index=False, na_rep='NA', sep='\t')
        else:
            df_write.to_csv(filename,
             index=False, na_rep='NA', sep='\t', mode='a', header=False)

# Preprocess all
print(datetime.now(), "Start processing with chunk size =", chunk_size)

# Re-initialize
reader = pd.read_csv(FILE_SOURCE, 
    chunksize=chunk_size, dtype=str, delimiter='\t')

print("Processing file No:")
n = 0
for r in reader:
    print(datetime.now(), n)
    func_split(r, l_cols, n)
    n += 1

print()
print(datetime.now())
print("Done.")

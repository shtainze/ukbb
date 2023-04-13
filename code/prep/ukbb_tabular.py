#############
# Process UKBB tabular files
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
DIR_UKBB_OLD=os.path.join(DIR_HOME, "data", "ukbb", "0000000_34134_axivity")
FILE_UKBB_OLD=os.path.join(DIR_UKBB_OLD, "ukb34134.csv")
DIR_UKBB_NEW=os.path.join(DIR_HOME, "data", "ukbb", "4020457_671006_all")
FILE_UKBB_NEW=os.path.join(DIR_UKBB_NEW, "ukb671006.csv")
DIR_ACCEL = os.path.join(DIR_HOME, "data", "accel")
FILE_ACCEL = os.path.join(DIR_ACCEL,
 "FEATURES_ABNORMAL_GROUP_NAME_NEW_RULE_RECORDING_INFO.txt")

# Output
DIR_OUT = os.path.join(DIR_HOME, "data", "ukbb", "tabular_processed")
FILE_UKBB_TRUNCATED = os.path.join(DIR_OUT, "ukb671006_truncated.csv")
FILE_UKBB_IDS = os.path.join(DIR_OUT, "pair_ids.csv")


print()
print(datetime.now(), "Start processing UKBB tabular data")


# #############
# # Extract a subset of 27 columns (out of the ~20k columns in total)
# #   that can be used for merge with the old dataset
# #############

# # Read the files
# df_old = pd.read_csv(FILE_UKBB_OLD, dtype=str)
# reader = pd.read_csv(FILE_UKBB_NEW, chunksize=50, dtype=str)

# # Get the column names
# l_cols_old = df_old.columns
# l_cols_new = reader.get_chunk(5).columns

# # Check that the columns of the old dataset is
# #   totally included in those of the new dataset
# print()
# print(len(l_cols_old), "&", len(l_cols_new),
#       "columns were found in the old & new datasets")
# print("Is the former totally included in the latter? :")
# print(set(l_cols_old) <= set(l_cols_new))

# # From df_new, extract only the columns common with df_old
# chunk_size = 5000
# def preprocess(df_new, l_cols_old, chunk_size):
#     print(datetime.now(), "processing...")
#     return df_new[l_cols_old]

# # Re-initialize
# reader = pd.read_csv(FILE_UKBB_NEW, chunksize=chunk_size, dtype=str)

# # Preprocess all
# print()
# print(datetime.now(), 
#     "Start processing with chunk size =",
#     chunk_size)
# df_new = pd.concat(
#     (preprocess(r, l_cols_old, chunk_size) for r in reader),
#      ignore_index=True)

# # Save
# df_new.to_csv(FILE_UKBB_TRUNCATED, index = False)
# print("Output completed:", FILE_UKBB_TRUNCATED)

# #############
# # ID extraction & merge of the old/new datasets
# #############

# print()
# print(datetime.now(), "Extract IDs...")

# df_new = pd.read_csv(FILE_UKBB_TRUNCATED, dtype=str)
# df_old = pd.read_csv(FILE_UKBB_OLD, dtype=str)
# l_cols_old = df_old.columns

# # Distinguish the ids
# df_old = df_old.rename(columns={'eid': 'eid_old'})

# # Get the column names
# l_cols_old = df_old.columns
# l_cols_new = df_new.columns

# l_cols_old_2 = [x for x in l_cols_old if not "eid" in x]
# l_cols_new_2 = [x for x in l_cols_new if not "eid" in x]

# # Check that the columns of the old dataset is
# #   totally included in those of the new dataset
# print(len(l_cols_old_2), "&", len(l_cols_new_2),
#       "columns were found in the old & new datasets")

# print("Is the former totally included in the latter? :")
# print(set(l_cols_old_2) <= set(l_cols_new_2))

# # Some entries cannot be distinguished
# #   and therefore must be omitted
# n_dup_old = sum(df_old.drop('eid_old', axis=1).duplicated())
# n_dup_new = sum(df_new.drop('eid', axis=1).duplicated())

# print(n_dup_old, "&", n_dup_new, "entries are indistinguishable")

# print(datetime.now(), "Omit those items...")
# df_old = df_old.drop_duplicates(subset=l_cols_old_2, keep=False)
# df_new = df_new.drop_duplicates(subset=l_cols_new_2, keep=False)

# n_dup_old = sum(df_old.drop('eid_old', axis=1).duplicated())
# n_dup_new = sum(df_new.drop('eid', axis=1).duplicated())

# print("Check that the omission was successful")
# print("Now", n_dup_old, "&", n_dup_new, "entries are indistinguishable")

# # Merge, preserving all the items (= outer merge)
# print()
# print(datetime.now(), "Merge...")
# df_merged = pd.merge(df_new, df_old, how='outer', indicator=True)

# print("The merged file has",
#       df_merged.shape[0], "entries, with",
#       df_merged[df_merged["_merge"] == "both"].shape[0],
#        "of them validly paired")

# # Extract ids
# df_ids = df_merged[df_merged["_merge"] == "both"][["eid_old", "eid"]]

# # Add the non-merged entries
# df_ids_2 = pd.merge(df_ids, df_new["eid"], how='outer', indicator=False)

# print(datetime.now(), "Exporting to csv...")
# df_ids.to_csv(FILE_UKBB_IDS, index=False)


#############
# csv -> tsv
#############

chunk_size = 5000
# From df_new, extract only the columns common with df_old
def process(df, str_dir, n):
    file_out = "formatted" + "_" + '{:0=4}'.format(n) + ".tsv" # formatted_0001.tsv, etc.
    file_out = os.path.join(str_dir, file_out)
    print(n, file_out)
    df.to_csv(file_out, sep='\t', index=False)

# Re-initialize
reader = pd.read_csv(FILE_UKBB_NEW, chunksize=chunk_size, dtype=str)

# Preprocess all
print()
print(datetime.now(),
    "Change the delimiter from comma to tab, for avoiding parser errors")
print("Processing with chunk size =", chunk_size)
print("Processing file No, name:")
n = 0
for r in reader:
    process(r, DIR_OUT, n)
    n += 1











#############
# Column split
# 
# The UKBiobank-ACCEL dataset is too huge to handle,
#   containing 28483 columns x 502387 rows.
# To ease handling, the dataset will be split into 28482 files,
#   consisting of the following two columns:
#       eid
#       One of the other 28482 columns
# Additionally, some of these separated files are merged
#    to make files for PLINK2 analysis, such as:
#       Covariate files (Age, Sex, 10 PCs, ..., Age * Sex, etc.)
#       Sleep-related subset
#############


print()
print(datetime.now(), "Done.")
print()
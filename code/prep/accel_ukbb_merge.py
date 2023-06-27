#############
# Merge old(34134) and new(671006) datasets
#############

from datetime import datetime
import sys, os, logging

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
DIR_UKBB_NEW=os.path.join(DIR_HOME, "data", "ukbb", "4047708_673112_all")
FILE_UKBB_NEW=os.path.join(DIR_UKBB_NEW, "ukb673112.csv")

# Output
DIR_OUT = os.path.join(DIR_UKBB_NEW, "accel_ukbb", "merging")
FILE_UKBB_OLD_TRUNCATED = os.path.join(DIR_OUT, "ukb34134_truncated.csv")
FILE_UKBB_NEW_TRUNCATED = os.path.join(DIR_OUT, "ukb671006_truncated.csv")
FILE_UKBB_MERGED = os.path.join(DIR_OUT, "ukb34134_ukb671006_merged.csv")
FILE_UKBB_IDS_SUCCESS = os.path.join(DIR_OUT, "pair_ids.csv")
FILE_UKBB_IDS_OLD_ONLY = os.path.join(DIR_OUT, "nonpaired_ids_old.csv")
FILE_UKBB_IDS_NEW_ONLY = os.path.join(DIR_OUT, "nonpaired_ids_new.csv")

if not os.path.exists(DIR_OUT):
    os.makedirs(DIR_OUT)

# Common columns that are used for matching across different datasets
l_cols_extract = ["eid", "31-0.0", "34-0.0", "52-0.0", "53-0.0", "54-0.0", "21000-0.0", "21003-0.0", "90001-0.0", "110006-0.0"]
# l_cols_matching = ["eid", "31-0.0", "34-0.0", "52-0.0", "53-0.0", "54-0.0", "21000-0.0", "21003-0.0", "110006-0.0"]
l_cols_matching = ["eid", "31-0.0", "34-0.0", "52-0.0", "53-0.0", "54-0.0", "21000-0.0", "21003-0.0", "90001-0.0", "110006-0.0"]

# Number of rows processed at once (change according to your machine memory size)
chunk_size = 5000

# From df_new, extract only the columns common with df_old
def preprocess(df_new, l_cols_matching, chunk_size):
    logging.info([datetime.now(), "processing..."])
    return df_new[l_cols_matching]

# Count the number of lines in the file
def count_rows(filename):
    with open(filename, 'r') as f:
        for i, line in enumerate(f):
            pass
    return i + 1


# Log file
# current_datetime = datetime.now().strftime("%Y%m%d_%H%M%S")
# filename = f"ukbb_tabular_processing_{current_datetime}.log"
filename = "accel_ukbb_merge.py.log"
FILE_LOG = os.path.join(DIR_OUT, filename)
print(f"Output written to file: {FILE_LOG}")

# Configure logging to output to both the console and a file
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(),  # Output to console
        logging.FileHandler(FILE_LOG)  # Output to file
    ]
)
# Example message
# message = "This is a log message"
# logging.info(message)

logging.info("##################################")
logging.info("Merge new/old UKBB datasets")
logging.info("")


#############
# Extract matching columns: old dataset
#############

logging.info([len(l_cols_extract), "columns will be extracted for preprocessing:", l_cols_extract])
logging.info("")

logging.info("Extract from the old dataset")
logging.info(FILE_UKBB_OLD)
df_old = pd.read_csv(FILE_UKBB_OLD, dtype=str)

l_cols_old = df_old.columns
logging.info([len(l_cols_old), "columns were found"])
logging.info(["Does the old dataset contain all the columns to be extracted? :",
    set(l_cols_matching) <= set(l_cols_old)])

logging.info("Counting the number of rows...")
num_rows = count_rows(FILE_UKBB_OLD)

logging.info(["Start extracting", num_rows, "rows"])
# Extract
df_old = df_old[l_cols_extract]
# Save
logging.info(["Processing completed. Export", FILE_UKBB_OLD_TRUNCATED])
df_old.to_csv(FILE_UKBB_OLD_TRUNCATED, index = False)
logging.info("Done export.")
logging.info("")


#############
# Extract matching columns: new dataset
#############

logging.info("Extract from the new dataset")
logging.info(FILE_UKBB_NEW)
reader = pd.read_csv(FILE_UKBB_NEW, chunksize=50, dtype=str)

l_cols_new = reader.get_chunk(5).columns
logging.info([len(l_cols_new), "columns were found"])
logging.info(["Does the old dataset contain all the columns to be extracted? :",
    set(l_cols_matching) <= set(l_cols_new)])

logging.info("Counting the number of rows...")
num_rows = count_rows(FILE_UKBB_NEW)

logging.info(["Start extracting", 
    num_rows,
    "rows with chunk size =",
    chunk_size
    ])
# Re-initialize
reader = pd.read_csv(FILE_UKBB_NEW, chunksize=chunk_size, dtype=str)
# Extract
df_new = pd.concat(
    (preprocess(r, l_cols_extract, chunk_size) for r in reader),
     ignore_index=True)
# Save
logging.info(["Processing completed. Export", FILE_UKBB_NEW_TRUNCATED])
df_new.to_csv(FILE_UKBB_NEW_TRUNCATED, index = False)
logging.info("Done export.")
logging.info("")


#############
# Merge of the old/new datasets
#   (trial on column-truncated datasets - not a production run)
# ID extraction
#############

df_new = pd.read_csv(FILE_UKBB_NEW_TRUNCATED, dtype=str)
df_old = pd.read_csv(FILE_UKBB_OLD_TRUNCATED, dtype=str)
l_cols_old = df_old.columns
l_cols_new = df_new.columns
l_ids_all_old = df_old["eid"].tolist()
l_ids_all_new = df_new["eid"].tolist()
logging.info([len(l_ids_all_old), "rows were found in the old dataset"])
logging.info([len(l_ids_all_new), "rows were found in the new dataset"])

# Check that the sets of columns are the same
logging.info([len(l_cols_old), "columns were found in the old dataset", l_cols_old])
logging.info([len(l_cols_new), "columns were found in the new dataset", l_cols_new])
logging.info(["Are the columns same? :", set(l_cols_old) == set(l_cols_new)])
logging.info("")

# Merge, preserving all the items (= outer merge)
logging.info(["Merge the two datasets using columns", l_cols_matching])
logging.info("")

df_old = df_old[l_cols_matching]
df_new = df_new[l_cols_matching]

# Some entries cannot be distinguished
#   and therefore must be omitted
n_dup_old = sum(df_old.drop('eid', axis=1).duplicated())
n_dup_new = sum(df_new.drop('eid', axis=1).duplicated())
logging.info([n_dup_old, n_dup_new, "entries are indistinguishable"])

logging.info("Omit those items...")
l_cols_old_2 = df_old.drop('eid', axis=1).columns
l_cols_new_2 = df_new.drop('eid', axis=1).columns
df_old = df_old.drop_duplicates(subset=l_cols_old_2, keep=False)
df_new = df_new.drop_duplicates(subset=l_cols_new_2, keep=False)
logging.info([df_old.shape[0], df_new.shape[0], 
      "rows are found in the old & new datasets"])

n_dup_old = sum(df_old.drop('eid', axis=1).duplicated())
n_dup_new = sum(df_new.drop('eid', axis=1).duplicated())

logging.info(["After omission", n_dup_old, n_dup_new, "entries are indistinguishable"])
logging.info("")

# Distinguish the ids
df_old = df_old.rename(columns={'eid': 'eid_old'})

# Merge
df_merged = pd.merge(df_new, df_old, 
    how='outer', indicator=True, validate="one_to_one")

logging.info(["The merged file has",
    df_merged.shape[0], "entries, with",
    df_merged[df_merged["_merge"] == "both"].shape[0],
    "of them validly paired"])

# Extract ids
df_ids = df_merged[df_merged["_merge"] == "both"][["eid_old", "eid"]]
l_ids_paired_old = df_ids["eid_old"].tolist()
l_ids_paired_new = df_ids["eid"].tolist()
l_ids_only_old = sorted(list(
    set(l_ids_all_old) - set(l_ids_paired_old)
    ))
l_ids_only_new = sorted(list(
    set(l_ids_all_new) - set(l_ids_paired_new)
    ))
logging.info(["No. of the non-merged entries (old, new):", len(l_ids_only_old), len(l_ids_only_new)])

logging.info(["Export", FILE_UKBB_MERGED])
df_merged.to_csv(FILE_UKBB_MERGED, index=False)

logging.info(["Export", FILE_UKBB_IDS_SUCCESS])
df_ids.to_csv(FILE_UKBB_IDS_SUCCESS, index=False)

logging.info(["Export", FILE_UKBB_IDS_OLD_ONLY])
with open(FILE_UKBB_IDS_OLD_ONLY, "w") as file:
    file.write("\n".join(l_ids_only_old))

logging.info(["Export", FILE_UKBB_IDS_NEW_ONLY])
with open(FILE_UKBB_IDS_NEW_ONLY, "w") as file:
    file.write("\n".join(l_ids_only_new))

logging.info("")
logging.info("Done export.")
logging.info("")


logging.info("")
logging.info("Done.")
logging.info("")

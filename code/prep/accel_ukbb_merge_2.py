#############
# Merge old(34134) and new(671006) datasets, refined
#############

import collections, csv, os, logging, re
from datetime import datetime
from pathlib import Path
import polars as pl


#############
# Set I/O
#############


# Input
DIR_HOME = os.getcwd()
DIR_SOURCE = os.path.join(DIR_HOME, "data", "accel_ukbb", "merging")
FILE_OLD = os.path.join(DIR_SOURCE, "nonpaired_data_old.csv")
FILE_NEW = os.path.join(DIR_SOURCE, "nonpaired_data_new.csv")
FILE_IDS_ALREADY_PAIRED = os.path.join(DIR_SOURCE, "pair_ids.csv")
DIR_OUT = DIR_SOURCE


def func_join_subset(df_old, df_new, cols_subset, cols_groupby):
    logging.info([df_old.shape[0], "entries are found in the old dataset"])
    logging.info([df_new.shape[0], "entries are found in the new dataset"])
    
    cols_subset_old = ["eid_old"] + cols_subset
    cols_subset_new = ["eid"] + cols_subset
    
    logging.info([len(cols_subset), "Columns used for join:", cols_subset])
    # Extract the part used for join
    # Omit duplicates to prevent wrong join
    df_old_for_join = (df_old[cols_subset_old]
                        .unique(subset=cols_subset, keep="none"))
    df_new_for_join = (df_new[cols_subset_new]
                        .unique(subset=cols_subset, keep="none"))

    logging.info([df_old_for_join.shape[0], "entries in the old dataset after omitting duplicates"])
    logging.info([df_new_for_join.shape[0], "entries in the new dataset after omitting duplicates"])
    logging.info("")

    # Join and extract successful matches
    df_ids_joined = (df_new_for_join
                 .join(df_old_for_join, on=cols_subset, 
                         how="inner")
                 .drop_nulls()[["eid", "eid_old"]]
                  )
    logging.info([df_ids_joined.shape[0], "entry pairs are successfully joined"])
    # Extract leftover IDs from the join
    ids_leftover_old = sorted(list(
        set(df_old["eid_old"]) - set(df_ids_joined["eid_old"])
    ))
    ids_leftover_new = sorted(list(
        set(df_new["eid"]) - set(df_ids_joined["eid"])
    ))
    # Extract leftover entries
    df_leftover_old = df_old.filter(pl.col("eid_old").is_in(ids_leftover_old))
    df_leftover_new = df_new.filter(pl.col("eid").is_in(ids_leftover_new))
    logging.info([df_leftover_old.shape[0], "entries in the old dataset remain unpaired"])
    logging.info([df_leftover_new.shape[0], "entries in the new dataset remain unpaired"])
    
    # Extract only the entries existing in both datasets
    # Concatenate the specified columns into the "grouped" colunn
    logging.info("Omit singletons")
    df_leftover_old_grouped = (df_leftover_old
                       .with_columns(
                           pl.concat_str(*cols_groupby).alias("grouped")
                       )
                      )

    df_leftover_new_grouped = (df_leftover_new
                       .with_columns(
                           pl.concat_str(*cols_groupby).alias("grouped")
                       )
                      )
    # Count
    df_leftover_old_count = df_leftover_old_grouped.groupby("grouped").agg(pl.count("grouped").alias("count"))
    df_leftover_new_count = df_leftover_new_grouped.groupby("grouped").agg(pl.count("grouped").alias("count"))
    # Extract the part common to the two datasets
    entry_exist_both = df_leftover_old_count.join(df_leftover_new_count, on="grouped", how="inner")["grouped"]
    entry_exist_both = list(entry_exist_both)
    df_leftover_old = (df_leftover_old_grouped
                        .filter(pl.col("grouped").is_in(entry_exist_both))
                        .drop("grouped")
                       )
    df_leftover_new = (df_leftover_new_grouped
                        .filter(pl.col("grouped").is_in(entry_exist_both))
                        .drop("grouped")
                       )
    logging.info([df_leftover_old.shape[0], "entries in the old dataset remain unpaired"])
    logging.info([df_leftover_new.shape[0], "entries in the new dataset remain unpaired"])
    logging.info("")

    df_leftover_all = (pl.concat([df_leftover_old, df_leftover_new]))
    return df_ids_joined, df_leftover_old, df_leftover_new, df_leftover_all


# Log file
# current_datetime = datetime.now().strftime("%Y%m%d_%H%M%S")
# filename = f"ukbb_tabular_processing_{current_datetime}.log"
filename = "accel_ukbb_merge_2.py.log"
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
logging.info("Merge new/old UKBB datasets - more attempts")
logging.info("")


#############
# Read the files and preprocess
#############


logging.info(["Import", FILE_OLD])
df_old = (pl.read_csv(FILE_OLD, separator=","))

logging.info(["Import", FILE_NEW])
df_new = (pl.read_csv(FILE_NEW, separator="\t",
                     infer_schema_length=0))

# Extract common columns
cols_old = df_old.columns
cols_new = df_new.columns
logging.info([len(cols_old), "columns were found in the old dataset"])
logging.info([len(cols_new), "columns were found in the new dataset"])
cols_common = sorted(list(
    set(cols_old) & set(cols_new)
))
logging.info([len(cols_common), "columns were found in both datasets"])
df_old = df_old[cols_common]
df_new = df_new[cols_common]

# Cast to string
for col_name in df_old.columns:
    df_old = df_old.with_columns(pl.col(col_name).cast(pl.Utf8))

# NA -> ""
for col_name in df_new.columns:
    df_new = df_new.with_columns(
        pl.col(col_name).str.replace("NA", "")
    )
    
# Change and add row
df_old = df_old.rename({"eid": "eid_old"})
df_old = df_old.with_columns(pl.lit(None).alias("eid").cast(pl.Utf8))
df_new = df_new.with_columns(pl.lit(None).alias("eid_old").cast(pl.Utf8))
# Make the orders of columns the same
df_new = df_new.select(df_old.columns)

# Omit complete duplicates
cols_except_id = [x for x in cols_common if not "eid" in x]
df_old = df_old.unique(subset=cols_except_id, keep="none")
df_new = df_new.unique(subset=cols_except_id, keep="none")


#############
# Join, extract ID pairs and leftover entries
#############

# Round 1
cols_subset = cols_except_id
cols_groupby = ["21000-0.0", # Ethnic background
                "31-0.0", # Sex
                "34-0.0", # Birth year
                "53-0.0", # Date of attending assessment centre, 1st
                "54-0.0", # Assessment centre
               ]
df_ids_joined_1, df_leftover_old_1, df_leftover_new_1, df_leftover_all_1 = func_join_subset(
    df_old, df_new, cols_subset, cols_groupby)


# Round 2
cols_subset = ["21000-0.0", # Ethnic background
                "31-0.0", # Sex
                "34-0.0", # Birth year
                "53-0.0", # Date of attending assessment centre, 1st
                "54-0.0", # Assessment centre
               ]
cols_groupby = ["21000-0.0", # Ethnic background
                "31-0.0", # Sex
                "34-0.0", # Birth year
                "53-0.0", # Date of attending assessment centre, 1st
                "54-0.0", # Assessment centre
               ]
df_ids_joined_2, df_leftover_old_2, df_leftover_new_2, df_leftover_all_2 = func_join_subset(
    df_leftover_old_1, df_leftover_new_1, cols_subset, cols_groupby)


# Round 3
cols_subset = ["53-0.0", # Date of attending assessment centre, 1st
               "53-1.0", # Date of attending assessment centre, 2nd
               "53-2.0", # Date of attending assessment centre, 3nd
                "54-0.0", # Assessment centre
               ]
cols_groupby = ["21000-0.0", # Ethnic background
                "31-0.0", # Sex
                "34-0.0", # Birth year
                "53-0.0", # Date of attending assessment centre, 1st
                "54-0.0", # Assessment centre
               ]
df_ids_joined_3, df_leftover_old_3, df_leftover_new_3, df_leftover_all_3 = func_join_subset(
    df_leftover_old_2, df_leftover_new_2, cols_subset, cols_groupby)


# Round 4
cols_subset = ["53-0.0", # Date of attending assessment centre, 1st
               "53-1.0", # Date of attending assessment centre, 2nd
               ]
cols_groupby = ["21000-0.0", # Ethnic background
                "31-0.0", # Sex
                "34-0.0", # Birth year
                "53-0.0", # Date of attending assessment centre, 1st
                "54-0.0", # Assessment centre
               ]
df_ids_joined_4, df_leftover_old_4, df_leftover_new_4, df_leftover_all_4 = func_join_subset(
    df_leftover_old_3, df_leftover_new_3, cols_subset, cols_groupby)



#############
# Merge ID pair lists and export
#############

logging.info(["Import", FILE_IDS_ALREADY_PAIRED])
df_ids_0 = pl.read_csv(FILE_IDS_ALREADY_PAIRED)
cols_order = df_ids_0.columns

df_ids_all = (pl.concat([
    df_ids_0,
    df_ids_joined_1.with_columns(pl.col(cols_order).cast(pl.Int64))[cols_order],
    df_ids_joined_2.with_columns(pl.col(cols_order).cast(pl.Int64))[cols_order],
    df_ids_joined_3.with_columns(pl.col(cols_order).cast(pl.Int64))[cols_order],
    df_ids_joined_4.with_columns(pl.col(cols_order).cast(pl.Int64))[cols_order],
])
              .sort(by="eid")
             )


FILE_OUT = os.path.join(DIR_SOURCE, "pair_ids_20230518.csv")
df_ids_all.write_csv(FILE_OUT)

logging.info("")
logging.info("Done.")
logging.info("")

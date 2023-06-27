#############
# Process UKBB tabular files
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
DIR_UKBB_NEW=os.path.join(DIR_HOME, "data", "ukbb", "4047708_673112_all")
FILE_UKBB_NEW=os.path.join(DIR_UKBB_NEW, "ukb673112.csv")

# Output
DIR_OUT = os.path.join(DIR_UKBB_NEW, "tabular_processed")
DIR_OUT_TAB = os.path.join(DIR_OUT, "tab")

if not os.path.exists(DIR_OUT_TAB):
    os.makedirs(DIR_OUT_TAB)

# Number of rows processed at once (change according to your machine memory size)
chunk_size = 5000

# From df_new, extract only the columns common with df_old
def preprocess(df_new, l_cols_matching, chunk_size):
    print(datetime.now(), "processing...")
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
filename = "ukbb_tabular_processing.log"
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
logging.info("Start processing UKBB tabular data")
logging.info("")



#############
# csv -> tsv
#############

logging.info("Change the delimiter from comma to tab, for avoiding parser errors")

# From df_new, extract only the columns common with df_old
def process(df, str_dir, n):
    file_out = "formatted" + "_" + '{:0=4}'.format(n) + ".tsv" # formatted_0001.tsv, etc.
    file_out = os.path.join(str_dir, file_out)
    print(n, file_out)
    df.to_csv(file_out, sep='\t', index=False)

# Re-initialize
reader = pd.read_csv(FILE_UKBB_NEW, chunksize=chunk_size, dtype=str)

# Preprocess all
logging.info(["Processing with chunk size =", chunk_size])
n = 0
for r in reader:
    process(r, DIR_OUT_TAB, n)
    n += 1

logging.info("")
logging.info("Done.")
logging.info("")

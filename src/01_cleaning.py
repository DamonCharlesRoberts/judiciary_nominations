# Title: Pre-processing of transcript data

# Notes:
	#* Description:
		#** A Script to do the pre-processing of transcript data.
		#** Refactored from the pre-processing.R script.
	#* Updated:
		#** 2023/10/17
		#** dcr

# Setup
	#* Load libraries
import polars as pl
import duckdb as db
from os import listdir, path
from preProcessing.loading import Cleaning
    #* Connect to a duckdb database
conn = db.connect("./data/project_database.db")
# Convert PDF's to a dataframe
dir_path = "./data/transcripts/female_poc/"

list_rel_files = listdir(dir_path)

list_files = [path.join(dir_path, x) for x in list_rel_files]

# Iterate over the pdf documents to produce a list of polars dataframes
list_dfs = [Cleaning.read_text(f) for f in list_files]
# Collapse the list of data.frames into a single data.frame
df = pl.concat(list_dfs, rechunk=True)

# Store the dataframe in the database
conn.execute(
    '''
    CREATE TABLE 
        transcript_text 
    AS SELECT 
        * 
    FROM 
        df
    COMMIT;
    '''
)
# Load CSV file of demographic data and put it in a SQL table
conn.execute(
    '''
    CREATE TABLE
        demographics
    AS SELECT
        *
    FROM
        read_csv_auto('./data/judge_demographic_data.csv')
    COMMIT;
    '''
)
conn.close()
# Now go to 02_cleaning.sql
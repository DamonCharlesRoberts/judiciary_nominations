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
from os import listdir, path, walk
from preProcessing.loading import Cleaning
    #* if running interactively, uncomment this and comment line above
#from src.preProcessing.loading import Cleaning
    #* Connect to a duckdb database
conn = db.connect("./data/project_database.db")
# Convert PDF's to a dataframe
dir_path = "./data/transcripts/"

list_files = [
    path.join(root, name) for root, dirs, files in walk(dir_path) for name in files if name.endswith('.pdf')
]

# Iterate over the pdf documents to produce a list of polars dataframes
list_dfs = [Cleaning.read_text(f) for f in list_files]
# Collapse the list of data.frames into a single data.frame
df = pl.concat(list_dfs, rechunk=True)

# Store the dataframe in the database
conn.execute(
    '''
    CREATE TABLE 
        TranscriptText 
    AS SELECT 
        * 
    FROM 
        df
    '''
)
# Load CSV file of demographic data and put it in a SQL table
conn.execute(
    '''
    CREATE VIEW
        Demographics
    AS SELECT
        *
    FROM
        read_csv_auto('./data/judge_demographic_data.csv')
    '''
)
conn.close()
# Now go to 02_cleaning.sql
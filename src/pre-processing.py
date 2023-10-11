# Title: Pre-processing of transcript data

# Notes:
	#* Description:
		#** A Script to do the pre-processing of transcript data.
		#** Refactored from the pre-processing.R script.
	#* Updated:
		#** 2023/10/1
		#** dcr

# Setup
	#* Load libraries
import polars as pl
from os import listdir, path
from src.helper import read_text

# Convert PDF's to a dataframe
dir_path = "./data/transcripts/female_poc/"

list_rel_files = listdir(dir_path)

list_files = [path.join(dir_path, x) for x in list_rel_files]


# Iterate over the pdf documents to produce a list of polars dataframes
list_dfs = list(map(read_text, list_files))

# Collapse the list of data.frames into a single data.frame
df = pl.concat(list_dfs, rechunk=True)
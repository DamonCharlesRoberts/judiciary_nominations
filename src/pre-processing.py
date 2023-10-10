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
from src.helper import read_text

# Convert PDF's to a dataframe
df = read_text()
df_2 = read_text(file = "./data/transcripts/female_poc/bryant_09-26-2006.pdf")
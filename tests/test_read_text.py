# Title: src.helper.read_text unit tests

# Notes:
	#* Description:
		#** Unit testing for the src.helper.read_text() function.
	#* Updated:
		#** 2023/10/11
		#** dcr

# Setup
	#* Load needed libraries
import sys
from os import listdir, path
	#* Load the pytest library
import pytest
	#* Load the function I am testing
sys.path.append("../src/")
from src.helper import read_text


# Run tests

class TestReadText:
	#* Check to make sure that will return one dataframe for one file
	def test_single_file(self):
		list_df = [read_text()]
		assert len(list_df) == 1
		#* Check to make sure that it returns three dataframes for three files
	def test_female_poc(self):
		dir_path = "./data/transcripts/female_poc/"

		list_rel_files = listdir(dir_path)

		list_files = [path.join(dir_path, x) for x in list_rel_files]

		list_dfs = list(map(read_text, list_files))
		assert len(list_dfs) == 3
		#* Check to make sure that the data.frames have 4 columns in them
	def test_n_column(self):
		df = read_text()
		assert len(df.columns) == 4
		#* Check to make sure that all of the columns are a string data type
	def test_column_type(self):
		df = read_text()
		list_types = df.dtypes
		list_types_adj = [str(x) for x in list_types]
		assert all(x == "Utf8" for x in list_types_adj)
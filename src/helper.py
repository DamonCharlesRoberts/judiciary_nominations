# Title: helper module

# Notes:
	#* Description:
		#** self-defined helper functions for the project
	#* Updated
		#** 2023/10/10
		#** dcr
# Dependencies
import re
import polars as pl

from PyPDF2 import PdfReader

def read_text(
        file = "./data/transcripts/female_poc/brown_10-22-2003.pdf"
    ):
    """Convert text in a confirmation hearing PDF to a polars data.frame

    Args:
    - file (str): A file path to a pdf document

    Returns:

    - pl.DataFrame object
    
    """
    # Define base pattern
        #* Looks for the titles (Chairman | Senator | Justice| etc.)...
        #* Followed by a space (\s)
        #* Then followed by 2 or more ({2,}) capital letters ([A-Z])
    base_pattern = r'Chairman\s[A-Z]{2,}|Senator\s[A-Z]{2,}|Justice\s[A-Z]{2,}|Judge\s[A-Z]{2,}|Mr\.\s[A-Z]{2,}|Ms\.\s[A-Z]{2,}|Mrs\.\s[A-Z]{2,}'

    # Load file
    file = PdfReader(file)

    # Read the contents of the file...
    # then convert into a python string.
    output = "" # make an empty string object
    for p in range(len(file.pages)): # for each page in the file
        page = file.pages[p] # grab the contents of each page
        output += page.extract_text() # and extract the text of the page...
        # and append to the string object
    # Clean up the string
        #* Remove the space or new line between first letter of lastname
        #* e.g., Senator L AEHY should be Senator LAEHY
        #* the regex pattern says....
        #* Find the words Chairman, Senator, Justice, etc.
        #* Look for a space between those words
        #* And then look for a single trailing capital letter
        #* But I should ignore situations where a capital letter is followed by
        #* a lower case letter
    improved_str = re.sub(
        # take this pattern
            #* looks for titles, then a space (\s) and then 1 ({1}) capital letter [A-Z]
            #* exclude situations where the upper case letter is followed by space (\s) and then a lower case letter (\?!([a-z]))
        r'([Chairman|Senator|Justice|Judge|Mr\.|Ms\.|Mrs\.]\s[A-Z]{1})\s(?!([a-z]))',
        r'\1', # and substitute the first element with the space
        output # do this throughout the output string
    )
        #* Now remove any and all \n characters
    improved_str_2 = re.sub(
        r'\n', # find all newline characters
        '', # and substitute them with no space
        improved_str # do this throughout the improved_str string
    )
        #* Split the string into a list.
        #* Specifically will create a list element per comment.
        #* the regex pattern says ...
        #* split the string into a new list element starting before the base pattern (?={base_pattern})
    list_split = re.split(
        # Use the look-forward ((?=)) operator ...
        # to identify each time the last chunk of the string...
        # to close the end of a list element and start a new one
        rf'(?={base_pattern})',
        # within the improved_str_2 string
        improved_str_2
        # then split it to create a new list element separate from what comes after
    )
    
    # Convert the list of strings to a polars dataframe
        #* take the list of strings and put them in a polars dataframe
        #* each row should correspond to each list element
        #* each list element should reflect a single comment by someone on the committee.
        #* so each row should follow the following pattern...
        #* Senator LAEHY . Some comment about something.
    df = pl.DataFrame({
        "raw_string": list_split
    })
        #* now, I want to separate who made the comment from the comment
    df_split = df.with_columns([ # grab the raw_string column
        # create a speaker column that grabs the information about who spoke
        # does this by finding a pattern like the following
        # Senator LAEHY . Some comment about something.
        # It puts the Senator LAEHY part in the speaker column
        # and it puts the . Some comment about something. part in the text column
        pl.col("raw_string").str.extract(rf'{base_pattern}', 0).alias("speaker"),
        pl.col("raw_string").str.replace(rf'{base_pattern}', "").alias("text")
	])

    # Grab the meta data for later. Specifically hearing date.
        #* Read the contents of the first page
    meta_page = file.pages[0] # grab the first page of the file
    meta_output = meta_page.extract_text() # store the text in the first page
    str_date = re.search(
        # Find all capitalized months 
        # followed by a space and a 1 or 2 digit date 
        # a comma then a space and then a four day digit
        r'(?:JANUARY|FEBRUARY|MARCH|APRIL|MAY|JUNE|JULY|AUGUST|SEPTEMBER|OCTOBER|NOVEMBER|DECEMBER)\s+\d{1,2},\s+\d{4}',
        # look for this in the meta_output string
        meta_output
    ).group(0) # once this has been found, grab that matching sub-string

    # Add the hearing date to a column in the dataframe
    df_cleaned = df_split.with_columns(
        # make a column called hearing_date
        # that takes the str_date string and pastes it in for each row
        hearing_date = pl.lit(str_date)
    )
    
    # return the cleaned polars dataframe
    return df_cleaned
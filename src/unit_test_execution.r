# Title: Run unit tests

# Notes:
    #* Description: 
        #** R file to run unit tests
    #* Updated:
        #** 2023-05-03
        #** dcr
# Run unit tests
testthat::test_dir("tests")

# Results
    #* filter_justices(): 4/4 pass
    #* frameify_text(): 4/4 pass
    #* transcripts_read(): 2/2 pass
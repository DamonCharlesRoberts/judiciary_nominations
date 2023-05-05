# Title: test helper/transcripts_read()

# Notes:
    #* Description:
        #** Test script for transcripts_read() function
    #* Updated:
        #** 2023-05-05
        #** dcr

# setup
    #* set path
setwd("../src")
    #* Load function
box::use(
    ./helper[transcripts_read]
    ,testthat[...]
)
    #* Run function
test_folder <- "../data/transcripts/female_poc"
result <- transcripts_read(
    folder = test_folder
)

# Tests
    #* return data.table objects in list
test_that(
    "data.table in list"
    ,{
        expect_s3_class(
            result[[1]]
            ,"data.table"
        ) 
    }
)
    #* return correct number of data.tables in list object
test_that(
    "lengths(list)"
    ,{
        expect_true(
            length(result) == 3
        )
    }
)

# Title: test helper/transcripts_read()

# Notes:
    #* Description:
        #** Test script for transcripts_read() function
    #* Updated:
        #** 2023-05-03
        #** dcr

# setup
    #* set path
setwd("src")
    #* Load function
box::use(
    ./helper[filter_demographics]
    , data.table[setDT]
    ,testthat[...]
)
    #* run function and store result
result <- filter_demographics()
# Tests
    #* Check the number of columns
test_that(
    "check columns"
    ,{
        expect_true(
            ncol(result) == ncol(result)
        )
    }
)
    #* Check that there is at least a names column
test_that(
    "check name col"
    ,{
        expect_true(
            "name" %in% colnames(
                result
            )
        )
    }
)
    #* check that there aren't duplicate rows
test_that(
    "check duplicate rows"
    ,{
        expect_true(
            nrow(
                result[
                    any(
                        duplicated(
                            result
                            , by = c(
                                "name"
                                ,"birthYear"
                                , "hearingYear"
                                , "courtType"
                            )
                        )
                    )
            ]
              
            ) == 0
        ) 
    }
)

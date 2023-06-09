# Title: test helper/frameify_text()

# Notes:
    #* Description:
        #** Test script for frameify_text() function
    #* Updated:
        #** 2023-05-03
        #** dcr

# setup
    #* set path
setwd("../src")
    #* Load function
box::use(
    ./helper[frameify_text]
    ,pdftools[pdf_text]
    ,testthat[...]
)
    #* load example file for tests
exampleFile <- pdf_text("../data/transcripts/female_poc/CHRG-108shrg93738.pdf")


# Testing
    #* Check to make sure the function returns a data.table object
test_that(
    "data.table"
    ,{
        expect_s3_class(
            frameify_text(exampleFile)
            ,"data.table"
        )   
    }
)
    #* check to make sure the data.table object has three columns
test_that(
    "ncol"
    ,{
        expect_equal(
            ncol(frameify_text(exampleFile))
            ,3
        )
    }
)
    #* check the names of the data.table columns...
    #* ... should be name, comment, title
test_that(
    "colnames"
    ,{
        expect_named(
            frameify_text(exampleFile)
            ,c(
                "name"
                ,"comment"
                ,"title"
            )
        )
    }
)
    #* check to make sure there are rows returned
test_that(
    "nrow"
    ,{
        expect_true(
            nrow(frameify_text(exampleFile)) != 0
        )
    }
)

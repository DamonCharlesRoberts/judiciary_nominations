# Title: test helper/filter_justices()

# Notes:
    #* Description:
        #** Test script for filter_justices() function
    #* Updated:
        #** 2023-05-03
        #** dcr

# setup
    #* set path
setwd("../src")
    #* Load function
box::use(
    ./helper[
        frameify_text
        ,filter_justices
    ]
    ,data.table[setDT]
    ,pdftools[pdf_text]
    ,testthat[...]
)

    #* make a data.table object out of an example document
        #** load example file for tests
exampleFile <- pdf_text("../data/transcripts/female_poc/CHRG-108shrg93738.pdf")
        #** make data.table of it
exampleDF <- frameify_text(
    exampleFile
)
        #** load demographics csv for names
nomineeDemographics <- setDT(
    read.csv(
        file = "../data/judge_demographic_data.csv"
    )
)
nomineeDemographics <- nomineeDemographics[
    ,name:=toupper(Last.Name)
]

# Tests
    #* check to make sure people provide an arg
test_that(
    "one arg"
    ,{
        expect_error(
            filter_justices()
        )
    }
)
    #* check that people provide both args
test_that(
    "both args"
    ,{
        expect_error(
            filter_justices(exampleDF)
        )
    }
)
    #* check to make sure that it doesn't return empty columns
test_that(
    "empty rows"
    ,{
        expect_true(
            nrow(
                filter_justices(
                    exampleDF
                    ,nomineeName=nomineeDemographics$name
                )
            ) !=0
        )
    }
)
    #* check to  make sure that it doesn't return specific titles
test_that(
    "bad titles"
    ,{
        expect_true(
            !(
                filter_justices(
                    exampleDF
                    ,nomineeName=nomineeDemographics$name
                )$title[[1]] %in% c("Senator", "Chairman")
            )
        )
    }
)

# Title: test helper/filter_justices()

# Notes:
    #* Description:
        #** Test script for filter_justices() function
    #* Updated:
        #** 2023-05-03
        #** dcr

# setup
    #* set path
setwd("./src")
    #* Load function
box::use(
    ./R/transcript_clean[
        frameify_text
        , filter_justices
    ]
    , data.table[setDT]
    , pdftools[pdf_text]
    , testthat[...]
)

    #* make a data.table object out of an example document
        #** load example file for tests
example_file <- pdf_text("../data/transcripts/female_poc/brown_10-22-2003.pdf")
        #** make data.table of it
example_df <- frameify_text(
    example_file
)
        #** load demographics csv for names
nominee_demographics <- setDT(
    read.csv(
        file = "../data/judge_demographic_data.csv"
    )
)
nominee_demographics <- nominee_demographics[
    , name := toupper(Last.Name)
]

# Tests
    #* check to make sure people provide an arg
test_that(
    "one arg"
    , {
        expect_error(
            filter_justices()
        )
    }
)
    #* check that people provide both args
test_that(
    "both args"
    , {
        expect_error(
            filter_justices(example_df)
        )
    }
)
    #* check to make sure that it doesn't return empty columns
test_that(
    "empty rows"
    , {
        expect_true(
            nrow(
                filter_justices(
                    example_df
                    , nominee_name = nominee_demographics$name
                )
            ) != 0
        )
    }
)
    #* check to  make sure that it doesn't return specific titles
test_that(
    "bad titles"
    , {
        expect_true(
            !(
                filter_justices(
                    example_df
                    , nominee_name = nominee_demographics$name
                )$title[[1]] %in% c("Senator", "Chairman")
            )
        )
    }
)

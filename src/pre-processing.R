# Title: pre-processing

# Notes:
    #* Description:
        #** R script to perform pre-processing
    #* Updated:
        #** 2023-05-03
        #** dcr

# Setup
    #* set path
setwd("./src")
    #* Load relevant functions
box::use(
    ./R/transcript_all[...]
    , ./R/interruption_counts[...]
    , data.table[
        setDT
        , rbindlist
    ]
)

# Load transcript and nominee information
cleaned_df <- transcript_clean(
    folder = "../data/transcripts/female_poc"
)

# Count
count_df <- interruption_counts(cleaned_df)
View(count_df)
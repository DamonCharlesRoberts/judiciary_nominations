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
    ./helper[
        transcript_clean
    ]
    ,data.table[
        setDT
        ,rbindlist
    ]
)

# Load transcript and nominee information
cleaned <- transcript_clean(
    folder = "../data/transcripts/female_poc"
)
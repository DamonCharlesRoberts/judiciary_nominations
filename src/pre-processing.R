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
        transcripts_read
        ,filter_justices
    ]
    ,data.table[
        setDT
        ,rbindlist
    ]
)
    #* Load nominee information
nomineeDemographics <- setDT(
    read.csv(
        file = "../data/judge_demographic_data.csv"
    )
)
nomineeDemographics <- nomineeDemographics[
    ,name:=toupper(Last.Name)
]

# read pdf files, and create data.table objects from them

femalePOCList <- transcripts_read(
    folder = "../data/transcripts/female_poc/"
)
malePOCList <- transcripts_read(
    folder = "../data/transcripts/male_poc/"
)
femaleWhiteList <- transcripts_read(
    folder = "../data/transcripts/female_white/"
)
maleWhiteList <- transcripts_read(
    folder = "../data/transcripts/male_white/"
)

# filter out non-nominee rows

femalePOCFiltered <- lapply(
    femalePOCList,
    filter_justices,
    nomineeName=nomineeDemographics$name
)
malePOCFiltered <- lapply(
    malePOCList,
    filter_justices,
    nomineeName=nomineeDemographics$name
)
femaleWhiteFiltered <- lapply(
    femaleWhiteList,
    filter_justices,
    nomineeName=nomineeDemographics$name
)
maleWhiteFiltered <- lapply(
    maleWhiteList,
    filter_justices,
    nomineeName=nomineeDemographics$name
)

# Collapse the list to one dataframe
femalePOC <- rbindlist(
    femalePOCFiltered
    ,idcol = TRUE
)[
    ,female:=1
][
    ,poc:=1
]
malePOC <- rbindlist(
    malePOCFiltered
    ,idcol = TRUE
)[
    ,female:=0
][
    ,poc:=1
]
femaleWhite <- rbindlist(
    femaleWhiteFiltered
    ,idcol = TRUE
)[
    ,female:=1
][
    ,poc:=0
]
maleWhite <- rbindlist(
    maleWhiteFiltered
    ,idcol = TRUE
)[
    ,female:=0
][
    ,poc:=0
]

# Collapse all dataframes into one
cleanList <- list(
    femalePOC
    ,malePOC
    ,femaleWhite
    ,maleWhite
)
cleanDF <- rbindlist(
    cleanList
)
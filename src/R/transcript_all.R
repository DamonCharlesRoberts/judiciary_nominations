# Title: transcript_all

# Notes:
    #* Description:
        #** R Script with transcript_all function
    #* Updated
        #** 2023-05-05
        #** dcr
# Setup
    #* define working directory
setwd("./src/R")
    #* define this as a module
'.__module__.'
    #* Load dependencies
box::use(
    ./transcript_clean[
        transcript_clean
    ]
    ,data.table[
        rbindlist
    ]
)

# Define function
#' @export
transcript_all <- function () {
    #' transcript_all
    #' 
    #' Description
    #' ----
    #' Read all transcripts from all four folders
    #' 
    #' Arguments
    #' ----
    #' NONE
    #' 
    #' Returns
    #' ----
    #' transcripts(data.table): a data.table object
    # make the prefix of the folder information
    prepend <- "../data/transcripts"
    suffix <- list(
        "female_poc"
        ,"male_poc"
        ,"female_white"
        ,"male_white"
    )
    # define the folder argument to be passed to transcript_clean 
    folder <- lapply(
        suffix
        , function (x) {
            paste(
                prepend
                ,x
                ,sep="/"
            )
        }
    )

    # make a list of data.table objects from each folder
    transcriptList <- lapply(
        folder,
        transcript_clean
    )
    names(transcriptList) <- suffix
    # combine list elements into one data.table object
    transcripts <- rbindlist(
        transcriptList
        ,idcol = TRUE
    )
}
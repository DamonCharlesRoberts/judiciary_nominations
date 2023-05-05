# Title: transcript_clean

# Notes:
    #* Description:
        #** R Script with transcript_clean function
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
    ./filter_demographics[
        filter_demographics
    ]
    ,./transcripts_read[
        transcripts_read
    ]
    ,data.table[
        rbindlist
        ,tstrsplit
    ]
)

# Define function
#' @export
transcript_clean <- function (folder) {
    #' transcript_clean
    #' 
    #' Description
    #' ----
    #' Wrapper function to do complete cleaning steps of transcripts
    #' 
    #' Arguments
    #' ----
    #' folder(str): a directory path to the transcripts
    #' 
    #' Returns
    #' ----
    #' transcriptDF(data.table): a data.table object
    
    # Clean the demographics data.frame
    demographicsClean <- filter_demographics()[
        ,hearingYear:=as.numeric(hearingYear)
    ]

    # Read the transcripts
    transcriptsLoaded <- transcripts_read(folder)

    # Clean the transcript data
    transcriptFiltered <- lapply(
        transcriptsLoaded
        ,filter_justices
        ,nomineeName=demographicsClean$name
    )

    # Collapse the transcript data into one dataframe
    transcriptFilteredDF <- rbindlist(
        transcriptFiltered
        ,idcol = TRUE
    )[
       ,c(
            "file_name"
            ,"hearingMonth"
            ,"hearingDay"
            ,"hearingYear"
        ):=tstrsplit(
            .id
            , '[_-]+'
        ) 
    ][
        ,hearingYear:=as.numeric(
            gsub(
                ".pdf"
                ,""
                ,hearingYear
            )
        )
    ]

    # Merge the demographics to the transcript data
    transcriptDF <- demographicsClean[
        transcriptFilteredDF
        ,on = c(
            "name"
            ,"hearingYear"
        )
    ]
}
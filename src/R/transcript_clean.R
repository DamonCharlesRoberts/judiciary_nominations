#' wrapper to read transcripts, clean them, and merge it with demographic data
#' 
'.__module__.'
#' dependencies
box::use(
    ./filter_demographics[
        filter_demographics
    ]
    ,./transcripts_read[
        transcripts_read
    ]
    ,./filter_justices[
        filter_justices
    ]
    ,data.table[
        rbindlist
        ,tstrsplit
    ]
)
#' transcript_clean
#' @param folder string argument
#' @return data.table
#' @export
transcript_clean <- function (folder) {
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
    return(transcriptDF)
}
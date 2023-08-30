#' filter out comments not made by a nominee from the transcript data
#' 
'.__module__.'
#' dependencies
box::use(
    ./transcript_read[
        transcript_read
    ]
)
#' filter_justices
#' @param df dataframe of transcript data
#' @param nomineeName vector of nominee names
#' @return data.table
#' @export
filter_justices <- function (df, nomineeName) {
    #' filter_justices
    #' 
    #' Description
    #' ----
    #' filters out rows from data.table elements of a list ...
    #' ... leaves only comments made by nominees
    #' 
    #' Arguments
    #' ----
    #' - df(data.table): data.table object
    #' - nomineeName(vector): vector of nominee last names
    #' 
    #' Returns
    #' ----
    #' filteredDF(data.table): data.table object
    
    badTitle <- c("Senator", "Chairman")
    filteredDF <- df[
        !(title %in% badTitle)
    ][
        name %in% nomineeName
    ]
    return(filteredDF)
}
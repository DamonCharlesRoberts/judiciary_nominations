# Title: filter_justices

# Notes:
    #* Description:
        #** R Script with filter_justices function
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
    ./transcript_read[
        transcript_read
    ]
)

# Define function
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
}
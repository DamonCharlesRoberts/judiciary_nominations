# Title: frameify_text

# Notes:
    #* Description:
        #** R Script with frameify_text function
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
    data.table[
        data.table
        ,tstrsplit
    ]
)

# Define funciton
#' @export
frameify_text <- function(rawList){
    #' frameify_text
    #' 
    #' Description
    #' ----
    #' Takes a list of raw text...
    #' ... extracts names and comments from each list element
    #' ... and puts in a data.frame
    #' Note: dependency function for transcripts_read
    #' 
    #' Arguments
    #' ----
    #' 
    #' - rawList(list): list of text
    #' 
    #' Depends
    #' ----
    #'
 
    # Convert list element into data.table object
    rawDF <- data.table(rawList)
    # Extract names and comments
        #* Define regex to find names based on titles
    positions <- gregexpr(
        '(Chairman|Senator|Justice|Judge|Mr.|Ms.|Mrs.) (\\b[A-Z]{2,}\\.|\\b[A-Z]{2,}\\b([continuing])\\.)'
        ,rawDF
    )[[1]]
        #* Find matches and determine how many characters long they are
    matchLengths <- attr(
        positions
        ,"match.length"
    )
        #* Use matchLengths to determine names
    names <- substring(
        rawDF
        ,positions
        ,positions + matchLengths - 1
    )
        #* Use matchLengths to determine comments
    commentStarts <- positions + matchLengths
    commentEnds <- c(
        positions[-1] -1
        ,nchar(rawDF)
    )
    comment <- substring(
        rawDF
        ,commentStarts
        ,commentEnds
    )
    # Turn it into a cleaned data.table object
    cleanDF <- data.table(
        name = names
        ,comment = comment
    )
    cleanDF <- cleanDF[
        ,name:=gsub(
            "."
            ,""
            ,name
            ,fixed=TRUE
        )
    ][
        ,c(
            "title"
            ,"name"
        ):=tstrsplit(
            name
            , " "
            , fixed = TRUE
        )
    ]
}
# Title: utils

# Notes:
    #* Description
        #** R Script with functions relied upon for project
    #* Updated
        #** 2023-05-03
        #** dcr
# Setup
    #* define this as a module
'.__module__.'
    #* load dependencies
box::use(
    pdftools[pdf_text]
    , data.table[
        data.table
        ,tstrsplit
    ]
    #,tm[...]
)

# Preprocessing functions
    #* frameify_text
#' @param rawList
#' @name rawList
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
 
    # Convert list element  into data.table object
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
    #* transcripts_read
#' @param folder
#' @name folder
#' @return cleanList
#' @export
transcripts_read = function(folder){
    #' transcripts_read
    #' 
    #' Description
    #' ----
    #' Takes a folder path, finds all of the pdf files in that directory...
    #' ... reads the text from the pdf files ...
    #' ... and organizes it into a data.frame
    #' 
    #' Arguments
    #' ----
    #' - folder(dir): the directory containing the pdf files needing to be read
    #' 
    #' Depends
    #' ---
    #' - pdftools::pdf_text()
    #' 
    
    #* Define the file path
    filePath <- paste(
        folder
        ,sep=""
    )

    # Create a vector list of file names in the defined directory
    fileVector <- list.files(
        filePath
        ,full.names = TRUE
    )

    # create a list object of the contents of the pdf files in the fileVector
    rawList <- lapply(
        fileVector
        ,pdf_text
    )
    # make each list element a cleaned data.table object
    cleanList <- lapply(
        rawList
        ,frameify_text
    )
    # return result
    return(cleanList)
}
    #* filter_justices
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
    
    filteredDF <- df[
        title != "Senator" & title != "Chairman"
    ][
        name %in% nomineeName
    ]
}
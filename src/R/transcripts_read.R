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
        transpose
    ]
    ,pdftools[
        pdf_text
    ]
    ,./frameify_text[
        frameify_text
    ]
)

# Define function
#' @export
transcripts_read <- function (folder) {
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
    # create list of names and dates
    fileNameSplit <- strsplit(
        fileVector
        ,split = "/"
    )
    listNames <- transpose(fileNameSplit)[[5]]
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
    names(cleanList) <- listNames
    # return result
    return(cleanList)
}
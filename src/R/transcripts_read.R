#' organizes the pdf text as a clean dataframe
'.__module__.'
#' dependencies
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

#' transcripts read
#' @param folder string argument
#' @return list of dataframes
#' @export
transcripts_read <- function (folder) {
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
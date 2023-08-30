#' load the pdf files and put the raw data in a dataframe
#' 
'.__module__.'
#' dependencies
box::use(
    data.table[
        data.table
        ,tstrsplit
    ]
)

#' frameify_text
#' @params rawList
#' @return data.table
#' @export
frameify_text <- function (rawList) { 
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
    return(cleanDF)
}
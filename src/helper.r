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
        setDT
        ,tstrsplit
        ,fifelse
        ,fcase
        ,setnames
    ]
    , utils[read.csv]
    #,tm[...]
)

# Preprocessing functions
    #* filter_demographics
#' @export
filter_demographics <- function () {
    #' filter_demographics
    #' 
    #' Description
    #' ----
    #' Loads the nominee background data and cleans it
    #' 
    #' Arguments
    #' ----
    #' NONE
    #' 
    #' Returns
    #' ----
    #' nomineeDF(data.table): data.table object
    
    # Load the data
    nomineeDF <- setDT(
        utils::read.csv(
            file = "../data/judge_demographic_data.csv"
        )
    )

    # clean up the dataframe
    nomineeDFClean <- nomineeDF[
        #** create lastname column
        ,name:=toupper(Last.Name)
    ][
        #** convert birth year to a numeric column
        ,birthYear:= as.numeric(Birth.Year)
    ][
        #** split the hearing date column into separate columns
        ,c(
            "hearingMonth"
            ,"hearingDay"
            ,"hearingYear"
        ):=tstrsplit(
            Hearing.Date..1.
            , "/"
            , fixed = TRUE
        )
    ][
        #** create a age column
            #** coded as: nominee age at time of hearing
        ,age:=as.numeric(hearingYear)-birthYear
    ][
        #** create a column for whether the president is Republican or not
            #** coded as: 1 = Republican nominating president, 0 = otherwise
        ,republican:=fifelse(
            Party.of.Appointing.President..1. == "Republican", 1, 0
            )
    ][
        #** create a column for whether the ABA rated nominee is qualified
            #** coded as: 0 = not qualified, 1 = qualified, 2 = well qualified, 3 = exceptionally well qualified
        ,abaQualified:=fcase(
            ABA.Rating..1. == "Not Qualified", 0,
            ABA.Rating..1. == "Qualified", 1,
            ABA.Rating..1. == "Well Qualified", 2,
            ABA.Rating..1. == "Exceptionally Well Qualified", 3
        )
    ][
        #** create a column for whether the committee confirmed nominee
            #** coded as: 0 = committee did not confirm, 1 = committee confirmed
        ,favorably:=fcase(
            Judiciary.Committee.Action..1. == "Reported (no recommendation recorded)", 0,
            Judiciary.Committee.Action..1. == "Reported (favorably)", 1
        )
    ][
        #** create a column for the court being nominated to
            #** coded as: 0 = other court, 1 = district court, 2 = court of appeals
        ,courtType:=fcase(
            Court.Type..1. == "Other", 0,
            Court.Type..1. == "U.S. District Court", 1,
            Court.Type..1. == "U.S. Court of Appeals", 2
        )
    ][
        #** create a column for the president that nominated them
            #** coded as: 1 = Bush, 2 = Obama, 3 = Trump
        ,president:=fcase(
            Appointing.President..1. == "George W. Bush", 1,
            Appointing.President..1. == "Barack Obama", 2,
            Appointing.President..1. == "Donald J. Trump", 3
        )
    ][
        #** create a column for whether committee was republican, democrat, or neither dominant
            #** coded as: <0 = margin of democrat advantage, 0 = even number, >0 = margin of republican advantage
        ,division:=fcase(
            hearingYear == 2019 | hearingYear == 2020, 2,
            hearingYear == 2017 | hearingYear == 2018, 1,
            hearingYear == 2015 | hearingYear == 2016, 2,
            hearingYear == 2013 | hearingYear == 2014, -2,
            hearingYear == 2011 | hearingYear == 2012, -2,
            hearingYear == 2009 | hearingYear == 2010, -6,
            hearingYear == 2007 | hearingYear == 2008, -2,
            hearingYear == 2005 | hearingYear == 2006, 1,
            hearingYear == 2003 | hearingYear == 2004, 1,
            hearingYear == 2001 | hearingYear == 2002, -1
        )
    ][
        #** create a column for whether committee composition was opposite of president's on party
            #** coded as: 0 = president and committee majority are not copartisans, 1 = president and committee majority are copartisans
        ,govDivided:=fcase(
            division > 0 & republican == 1, 0,
            division > 0 & republican == 0, 1,
            division < 0 & republican == 1, 1,
            division < 0 & republican == 0, 0
        )
    ][
        #** select only these new columns
        , name:govDivided
    ][
        #** filter out nominees pre-2000
        hearingYear >= 2000,
    ]

    # get unique nominees
    nomineeDFUnique <- nomineeDFClean[
        #* get unique rows based on the name column
        ,unique(name)
        ,by = list(
        #* but they should also match on these columns too
            birthYear
            ,hearingYear
            ,courtType
        )
    ]

    # return final nomineeDF
    nomineeDFFinal <- setnames(
        nomineeDFUnique
        ,old="V1"
        ,new="name"
        )
    return(nomineeDFFinal)
}
    #* frameify_text
#' @param rawList
#' @name rawList
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
    
    badTitle <- c("Senator", "Chairman")
    filteredDF <- df[
        !(title %in% badTitle)
    ][
        name %in% nomineeName
    ]
}
    #* interruption_counts
#' @export
interruption_counts <- function(df) {
    #' interruption_counts
    #' 
    #' Description
    #' ----
    #' creates a column counting the number of interruptions a nominee faces
    #' 
    #' Arguments
    #' ----
    #' - df(data.table): data.table object
    #' 
    #' Returns
    #' ----
    #' - countDF(data.table): data.table object
    countDF <- df[
        #** create a new column with NA values
        ,count:=NA_integer_
    ][
        #** update the count column and add count of em-dashes for the row
        ,count:=str_count(comments, pattern="—{2,}")
    ]
}
    #* clean_dataframe
#' @export
clean_dataframe <- function (df) {
    #' clean_dataframe
    #' 
    #' Description
    #' ----
    #' does some data cleaning to useful columns...
    #' ... such as hearing date, birthyear of nominee...
    #' ... PID of nominating president, aba rating ...
    #' ... ultimate action by committee ...
    #' ... court type, whether it was divided government ...
    #' 
    #' Arguments
    #' ----
    #' - df(data.table): data.table object
    #' 
    #' Returns
    #' ----
    #' cleanDF(data.table): data.table object
        #** get count of interruptions for each row
    
    countDF <- interruption_counts(df)
        
    
}
    #* transcript_clean
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
    demographicsClean <- filter_demographics()

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
    )

    # Merge the demographics to the transcript data
    transcriptDF <- demographicsClean[transcriptFilteredDF, on = "name"]

}
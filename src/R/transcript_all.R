utils::globalVariables(c(":="))
#' @title frameify_text
#'
#' @description
#' Takes loaded PDF input and then converts them into a data.frame object.
#'
#' @details
#' This function is a nested function for the transcripts_read function.
#' This function takes the loaded in PDF input file and then converts the
#' data from the pdf into a data.frame object. It determines the rows through
#' regex matching.
#'
#' @importFrom data.table data.table :=
#' @importFrom base gregexpr attr substring nchar substring gsub
#' @param raw_list
#' @return data.table
#' @export
frameify_text <- function(raw_list) { # nolint
    # Convert list element into data.table object
    raw_df <- data.table::data.table(raw_list)
    # Extract names and comments
        #* Define regex to find names based on titles
    positions <- base::gregexpr(
        "(Chairman|Senator|Justice|Judge|Mr.|Ms.|Mrs.) (\\b[A-Z]{2,}\\.|\\b[A-Z]{2,}\\b([continuing])\\.)" #nolint
        , raw_df
    )[[1]]
        #* Find matches and determine how many characters long they are
    match_lengths <- base::attr(
        positions
        , "match.length"
    )
        #* Use match_lengths to determine names
    names <- base::substring(
        raw_df
        , positions
        , positions + match_lengths - 1
    )
        #* Use matchLengths to determine comments
    comment_starts <- positions + match_lengths
    comment_ends <- c(
        positions[-1] - 1
        , base::nchar(raw_df)
    )
    comment <- base::substring(
        raw_df
        , comment_starts
        , comment_ends
    )
    # Turn it into a cleaned data.table object
    clean_df <- data.table::data.table(
        name = names
        , comment = comment
    )
    clean_df <- clean_df[
        , name := base::gsub( #nolint
            "."
            , ""
            , name
            , fixed = TRUE
        )
    ][
        , c(
            "title"
            , "name"
        ) := data.table::tstrsplit( #nolint
            name
            , " "
            , fixed = TRUE
        )
    ]
    return(clean_df)
}

#' @title transcripts_read
#'
#' @description
#'
#' Loading the pdf files of the transcripts
#' and organizing them into a dataframe object.
#'
#' @details
#'
#' This function takes pdf files in a single directory
#' and loads each of those pdf files.
#' Once it has loaded the pdf files, it then concatenates
#' them into a list of data.frame objects.
#'
#' @importFrom base paste list.files strsplit lapply names
#' @importFrom purrr transpose
#' @importFrom pdftools pdf_text
#' @param folder string argument
#' @return list of data.frames
#' @export
transcripts_read <- function(folder) {
    #* Define the file path
    file_path <- base::paste(
        folder
        , sep = ""
    )

    # Create a vector list of file names in the defined directory
    file_vector <- base::list.files(
        file_path
        , full.names = TRUE
    )
    # create list of names and dates
    file_name_split <- base::strsplit(
        file_vector
        , split = "/"
    )
    list_names <- purrr::transpose(file_name_split)[[5]]
    # create a list object of the contents of the pdf files in the fileVector
    raw_list <- base::lapply(
        file_vector
        , pdftools::pdf_text
    )
    # make each list element a cleaned data.table object
    clean_list <- base::lapply(
        raw_list
        , frameify_text
    )
    base::names(clean_list) <- list_names
    # return result
    return(clean_list)
}

#' @title filter_demographics
#'
#' @description
#' Loads a CSV file that contains demographic data on nominees.
#' With those data, the function then filters out some of the more
#' relevant demographic data that can be used to construct
#' a data.frame with not only the comments but the background
#' information on the justice in the transcript_clean function.
#'
#' @details
#' This function loads a CSV file containing the demographic data on nominees.
#' It then filters out and cleans the demographic data provided by the loaded
#' CSV file and returns the resulting data.frame object.
#'
#' @importFrom data.table setDT := tstrsplit fifelse fcase setnames
#' @importFrom utils read.csv
#' @importFrom base toupper as.numeric unique list
#' @return data.table
#' @export
filter_demographics <- function() { # nolint
    # Load the data
    nominee_df <- data.table::setDT(
        utils::read.csv(
            file = "../data/judge_demographic_data.csv"
        )
    )

    # clean up the dataframe
    nominee_clean_df <- nominee_df[
        #** create last name column
        , name := base::toupper(Last.Name) #nolint
    ][
        #** convert birth year to a numeric column
        , birth_year := base::as.numeric(Birth.Year) #nolint
    ][
        #** split the hearing date column into separate columns
        , c(
          "hearing_month"
          , "hearing_day"
          , "hearing_year"
        ) := data.table::tstrsplit( #nolint
            Hearing.Date..1. # nolint
            , "/"
            , fixed = TRUE
        )
    ][
        #** create a age column
            #** coded as: nominee age at time of hearing
        , age := base::as.numeric(hearing_year) - birth_year #nolint
    ][
        #** create a column for whether the president is Republican or not
            #** coded as: 1 = Republican nominating president, 0 = otherwise
        , republican := data.table::fifelse( #nolint
            Party.of.Appointing.President..1. == "Republican", 1, 0 # nolint
            )
    ][
        #** create a column for whether the ABA rated nominee is qualified
            #** coded as: 0 = not qualified, 1 = qualified, 2 = well qualified, 3 = exceptionally well qualified #nolint
        , aba_qualified := data.table::fcase( #nolint
            ABA.Rating..1. == "Not Qualified", 0, # nolint
            ABA.Rating..1. == "Qualified", 1,
            ABA.Rating..1. == "Well Qualified", 2,
            ABA.Rating..1. == "Exceptionally Well Qualified", 3
        )
    ][
        #** create a column for whether the committee confirmed nominee
            #** coded as: 0 = committee did not confirm, 1 = committee confirmed
        , favorably := data.table::fcase( #nolint
            Judiciary.Committee.Action..1. == "Reported (no recommendation recorded)", 0, #nolint
            Judiciary.Committee.Action..1. == "Reported (favorably)", 1
        )
    ][
        #** create a column for the court being nominated to
            #** coded as: 0 = other court, 1 = district court, 2 = court of appeals #nolint
        , court_type := data.table::fcase( #nolint
            Court.Type..1. == "Other", 0, # nolint
            Court.Type..1. == "U.S. District Court", 1,
            Court.Type..1. == "U.S. Court of Appeals", 2
        )
    ][
        #** create a column for the president that nominated them
            #** coded as: 1 = Bush, 2 = Obama, 3 = Trump
        , president := data.table::fcase( #nolint
            Appointing.President..1. == "George W. Bush", 1, # nolint
            Appointing.President..1. == "Barack Obama", 2,
            Appointing.President..1. == "Donald J. Trump", 3
        )
    ][
        #** create a column for whether committee was republican, democrat, or neither dominant #nolint
            #** coded as: <0 = margin of democrat advantage, 0 = even number, >0 = margin of republican advantage #nolint
        , division := data.table::fcase( #nolint
            hearing_year == 2019 | hearing_year == 2020, 2,
            hearing_year == 2017 | hearing_year == 2018, 1,
            hearing_year == 2015 | hearing_year == 2016, 2,
            hearing_year == 2013 | hearing_year == 2014, -2,
            hearing_year == 2011 | hearing_year == 2012, -2,
            hearing_year == 2009 | hearing_year == 2010, -6,
            hearing_year == 2007 | hearing_year == 2008, -2,
            hearing_year == 2005 | hearing_year == 2006, 1,
            hearing_year == 2003 | hearing_year == 2004, 1,
            hearing_year == 2001 | hearing_year == 2002, -1
        )
    ][
        #** create a column for whether committee composition was opposite of president's on party #nolint
            #** coded as: 0 = president and committee majority are not copartisans, 1 = president and committee majority are copartisans #nolint
        , gov_divided := data.table::fcase( #nolint
            division > 0 & republican == 1, 0,
            division > 0 & republican == 0, 1,
            division < 0 & republican == 1, 1,
            division < 0 & republican == 0, 0
        )
    ][
        #** select only these new columns
        , name:gov_divided
    ][
        #** filter out nominees pre-2000
        hearing_year >= 2000,
    ]

    # get unique nominees
    nominee_unique_df <- nominee_clean_df[
        #* get unique rows based on the name column
        , base::unique(name) #nolint
        , by = list(
        #* but they should also match on these columns too
            birth_year #nolint
            , hearing_year #nolint
            , court_type #nolint
        )
    ]

    # return final nomineeDF
    nominee_final_df <- data.table::setnames(
        nominee_unique_df
        , old = "V1"
        , new = "name"
        )
    return(nominee_final_df)
}

#' @title filter_justices
#'
#' @description
#' Takes a data.frame object and selects only the rows representing nominees.
#'
#' @details
#' This nested function takes a data.frame object from the frameify
#' and transcript_read functions and finds the rows representing
#' comments from the justices, then filters out any comments made by
#' members of the confirmation committee.
#'
#' @importFrom base %in%
#' @importFrom data.table
#' @param df dataframe of transcript data
#' @param nomineeName vector of nominee names
#' @return data.table
#' @export
filter_justices <- function(df, nominee_name) {
    bad_title <- c("Senator", "Chairman")
    filtered_df <- df[
        !(title %in% bad_title)
    ][
        name %in% nominee_name #nolint
    ]
    return(filtered_df)
}

#' @title transcript_clean
#'
#' @description
#' A wrapper function that takes all of the pdf files in
#' a given directory (the input), and uses nested functions
#' that read the file, put it in a data.frame object,
#' then stores all of the data in a list and filters out
#' comments made by senators to detect comments made by the
#' justices.
#'
#' @details
#' This function takes a string argument that identifies what the
#' directory of the folder containing the pdf files are in.
#' The function then uses nested functions that load the file,
#' put the file in a data.frame object, and cleans it up a bit.
#'
#' @importFrom data.table := rbindlist tstrsplit
#' @importFrom base as.numeric lapply gsub
#'
#' @param folder string argument
#' @return data.table
#' @export
transcript_clean <- function(folder) { # nolint
    # Clean the demographics data.frame
    demographics_clean <- filter_demographics()[
        , hearing_year := base::as.numeric(hearing_year) #nolint
    ]

    # Read the transcripts
    transcripts_loaded <- transcripts_read(folder)

    # Clean the transcript data
    transcript_filtered <- base::lapply(
        transcripts_loaded
        , filter_justices
        , nominee_name = demographics_clean$name
    )

    # Collapse the transcript data into one dataframe
    transcripts_filtered_df <- data.table::rbindlist(
        transcript_filtered
        , idcol = TRUE
    )[
       , c(
          "file_name"
          , "hearing_month"
          , "hearing_day"
          , "hearing_year"
        ) := data.table::tstrsplit( #nolint
            .id #nolint
            , "[_-]+"
        )
    ][
        , hearing_year := base::as.numeric( #nolint
            base::gsub(
                ".pdf"
                , ""
                , hearing_year
            )
        )
    ][
        , comment := stringr::str_trim(comment)
    ]

    # Merge the demographics to the transcript data
    transcript_df <- demographics_clean[
        transcripts_filtered_df
        , on = c(
          "name"
          , "hearing_year"
        )
    ]
    return(transcript_df)
}

#' @title transcript_all
#'
#' @description
#' Wrapper function that takes all files from all four folders and applies
#' the transcript_clean wrapper function to it.
#'
#' @details
#' This function uses nested functions that
#' read each pdf file, loads it, converts it to a data.frame object,
#' merges demographic data, and filters out comments not made by the nominee.
#' It does this for every file in all four folders.
#'
#' @importFrom base lapply paste
#' @importFrom data.table rbindlist
#' @return data.table
#' @export
transcript_all <- function() {
    # make the prefix of the folder information
    prepend <- "../data/transcripts"
    suffix <- list(
        "female_poc"
        , "male_poc"
        , "female_white"
        , "male_white"
    )
    # define the folder argument to be passed to transcript_clean
    folder <- base::lapply(
        suffix
        , function(x) {
            paste(
                prepend
                , x
                , sep = "/"
            )
        }
    )

    # make a list of data.table objects from each folder
    transcript_list <- base::lapply(
        folder,
        transcript_clean
    )
    names(transcript_list) <- suffix
    # combine list elements into one data.table object
    transcripts <- data.table::rbindlist(
        transcript_list
        , idcol = TRUE
    )
    return(transcripts)
}
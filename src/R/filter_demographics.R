#' load the nominee background data and clean it
#' 
'.__module__.'
#' dependencies
box::use(
    utils[read.csv]
)
#' filter_demographics
#' @return data.table
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

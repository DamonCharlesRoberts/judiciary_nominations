# Title: interruption_counts

# Notes:
    #* Description:
        #** R Script with interruption_counts function
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
    
)

# Define function
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
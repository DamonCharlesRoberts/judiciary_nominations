# Title: clean_dataframe

# Notes:
    #* Description:
        #** R Script with clean_dataframe function
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
    ./interruption_counts[
        interruption_counts
    ]
)

# Define function
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
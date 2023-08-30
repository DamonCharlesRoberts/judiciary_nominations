#' @title interruption_counts
#'
#' @description
#' Detects and records the number of interruptions based on presence
#' of em-dashes.
#'
#' @details
#' This function determines the number of interruptions made by members
#' of the committee for all nominees based on the presence of em-dashes.
#' It documents the count for each member by creating a new column.
#'
#' @importFrom data.table :=
#' @importFrom stringr::str_count
interruption_counts <- function(df) { # nolint
    count_df <- df[
        #** create a new column with NA values
        , count := NA_integer_ # nolint
    ][
        #** update the count column and add count of em-dashes for the row
        , count := stringr::str_count(
          comment # nolint
          , pattern = "(^—|—\\\\n$)"
        )
    ]
    return(count_df)
}

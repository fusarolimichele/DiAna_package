#' Retrieve Drug Names from FAERS Database
#'
#' This function retrieves drug names and their occurrence percentages from the FDA Adverse Event Reporting System (FAERS) database for a specified drug substance.
#'
#' @param drug Character string representing the drug substance for which drug names are to be retrieved.
#'
#' @return A data table containing drug names and their corresponding occurrence percentages.
#'
#' @details
#' The function imports data from the "DRUG" and "DRUG_NAME" tables in the specified quarter of the FAERS database. It calculates the total number of occurrences for each unique drug name and orders the results in descending order based on occurrence count. The resulting data table includes drug names and their occurrence percentages.
#'
#' @seealso \code{\link{import}}
#'
#' @examples
#' \dontrun{
#' # Specify the FAERS_version variable before calling the function
#' FAERS_version <- "2023Q2"
#' # Retrieve drug names for the substance "example_drug"
#' result <- get_drugnames("aripiprazole")
#' print(result)
#' result <- get_drugnames("atogepant")
#' print(result)
#' }
#'
#' @export
get_drugnames <- function(drug) {
  t <- import("DRUG", quarter = FAERS_version, save_in_environment = FALSE)[substance == drug]
  t <- import("DRUG_NAME", quarter = FAERS_version, save_in_environment = FALSE)[t, on = c("primaryid", "drug_seq")]
  t <- t[, .N, by = "drugname"][order(-N)][, perc := N / sum(N)]
}

#' Retrieve Drug Names from FAERS Database
#'
#' This function retrieves drug names and their occurrence percentages from the FDA Adverse Event Reporting System (FAERS) database for a specified drug substance.
#'
#' @param drug Character string representing the drug substance for which drug names are to be retrieved.
#' @param temp_d Drug database. Can be set to sample_Drug for testing.
#' @param temp_d_name Drug_name database. Can be set to sample_Drug_Name for testing.
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
#' # This example needs that setup_DiAna has been run before, to download DiAna dictionary
#' if (file.exist("external_source/DiAna_dictionary.csv")) {
#'   FAERS_version <- "24Q1"
#'   result <- get_drugnames("aripiprazole")
#'   print(result)
#' }
#' }
#' @export
get_drugnames <- function(drug, temp_d = Drug, temp_d_name = Drug_name) {
  t <- temp_d[substance == drug]
  t <- temp_d_name[t, on = c("primaryid", "drug_seq")]
  t <- t[, .N, by = "drugname"][order(-N)][, perc := N / sum(N)]
}

#' Fix DiAna Dictionary Locally
#'
#' This function updates the DiAna dictionary based on changes specified in an Excel file. It imports necessary data, identifies records to be fixed, and updates the dictionary accordingly.
#'
#' @param changes_xlsx_name A string specifying the name of the Excel file containing the changes.
#' @return A data.table with the updated Drug information.
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Reads the changes from the specified Excel file.
#'   \item Imports the necessary data tables (`DRUG_NAME` and `DRUG`) if they do not already exist.
#'   \item Identifies the records in `Drug_name` that need to be fixed based on the changes.
#'   \item Joins the changes with the identified records and updates the `Drug` table.
#'   \item Removes the old records and adds the updated records to the `Drug` table.
#' }
#' @importFrom readxl read_xlsx
#' @importFrom dplyr distinct
#' @examples
#' # This example needs that DiAna dictionary is downloaded (using setup_DiAna),
#' # and that an excel file with intended changes is available
#' if (file.exist("changes.xlsx") & file.exist("external_source/DiAna_dictionary.csv")) {
#'   Drug <- Fix_DiAna_dictionary_locally("changes.xlsx")
#' }
#' @export
Fix_DiAna_dictionary_locally <- function(changes_xlsx_name) {
  changes <- setDT(readxl::read_xlsx(paste0(path, changes_xlsx_name)))
  if (!exists("Drug_name")) import("DRUG_NAME", quarter = FAERS_version)
  if (!exists("Drug")) import("DRUG", quarter = FAERS_version)
  tobefixed <- Drug_name[drugname %in% changes$drugname]
  tobefixed <- changes[tobefixed, on = "drugname"]
  tobefixed <- dplyr::distinct(Drug[, .(primaryid, drug_seq, role_cod)])[tobefixed, on = c("primaryid", "drug_seq")]
  tobefixed <- tobefixed[, .(primaryid, drug_seq, substance, role_cod)]
  toberemoved <- Drug[tobefixed[, .(primaryid, drug_seq)], on = c("primaryid", "drug_seq")]
  Drug <- setdiff(Drug, toberemoved)
  Drug <- rbindlist(list(Drug, tobefixed))
  return(Drug)
}

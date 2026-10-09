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
#' get_drugnames("adalimumab", temp_d = sample_Drug, temp_d_name = sample_Drug_Name)
#' @export
get_drugnames <- function(drug, temp_d = Drug, temp_d_name = Drug_name) {
  check_workspace_defaults(c("temp_d", "temp_d_name"))
  t <- temp_d[substance == drug]
  t <- temp_d_name[t, on = c("primaryid", "drug_seq")]
  t <- t[, .N, by = "drugname"][order(-N)][, perc := N / sum(N)]
}

#' Fix DiAna Dictionary Locally
#'
#' This function updates the DiAna dictionary based on changes specified in an Excel file. It imports necessary data, identifies records to be fixed, and updates the dictionary accordingly.
#'
#' @param changes_xlsx_name Path of the Excel file containing the changes, with
#'   the columns `drugname` (raw drug name) and `substance` (the active
#'   ingredient it should be translated to).
#' @param temp_drug Drug dataset. Defaults to `Drug` if it is in your
#'   workspace; otherwise it is imported for the quarter in `FAERS_version`.
#' @param temp_drug_name Drug_name dataset. Defaults to `Drug_name` if it is in
#'   your workspace; otherwise it is imported for the quarter in `FAERS_version`.
#' @return A data.table with the updated Drug information.
#' @details
#' The function performs the following steps:
#' \itemize{
#'   \item Reads the changes from the specified Excel file.
#'   \item Uses the `Drug` and `Drug_name` tables, importing them if they are not available.
#'   \item Identifies the records in `Drug_name` that need to be fixed based on the changes.
#'   \item Replaces the substance of those records in the `Drug` table.
#' }
#' @importFrom readxl read_xlsx
#' @importFrom dplyr distinct
#' @examples
#' changes <- tempfile(fileext = ".xlsx")
#' writexl::write_xlsx(data.frame(drugname = "humira", substance = "adalimumab"), changes)
#' Drug <- Fix_DiAna_dictionary_locally(changes,
#'   temp_drug = sample_Drug, temp_drug_name = sample_Drug_Name
#' )
#' unlink(changes)
#' @export
Fix_DiAna_dictionary_locally <- function(changes_xlsx_name,
                                         temp_drug = NULL,
                                         temp_drug_name = NULL) {
  changes <- setDT(readxl::read_xlsx(changes_xlsx_name))
  check_columns(changes, c("drugname", "substance"), "changes_xlsx_name")
  if (is.null(temp_drug_name)) {
    temp_drug_name <- if (exists("Drug_name")) get("Drug_name") else import_from_FAERS_version("DRUG_NAME")
  }
  if (is.null(temp_drug)) {
    temp_drug <- if (exists("Drug")) get("Drug") else import_from_FAERS_version("DRUG")
  }
  tobefixed <- temp_drug_name[drugname %in% changes$drugname]
  tobefixed <- changes[tobefixed, on = "drugname"]
  tobefixed <- dplyr::distinct(temp_drug[, .(primaryid, drug_seq, role_cod)])[tobefixed, on = c("primaryid", "drug_seq")]
  tobefixed <- tobefixed[, .(primaryid, drug_seq, substance, role_cod)]
  # drop the old records of the fixed drugs (anti-join), then add the corrected ones
  kept <- temp_drug[!tobefixed, on = c("primaryid", "drug_seq")]
  rbindlist(list(kept, tobefixed), use.names = TRUE, fill = TRUE)
}

#' Import a table for the quarter in FAERS_version, without assigning it
#' @noRd
import_from_FAERS_version <- function(df_name) {
  check_workspace_object("FAERS_version")
  import(df_name, quarter = get("FAERS_version"), save_in_environment = FALSE)
}

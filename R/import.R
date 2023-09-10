#' @title import
#' @name import
#'
#' @description
#' Imports the specified FAERS relational database.
#'
#' @param df_name Name of the data file (without the ".rds" extension).
#'                It can be one of the following:
#'       \itemize{
#'                \item \emph{DRUG} =  Suspect and concomitant drugs (active ingredient);
#'                \item \emph{REAC} =  Suspect reactions (MedDRA PT);
#'                \item \emph{DEMO} =  Demographics and Reporting;
#'                \item \emph{DEMO_SUPP} =  Demographics and Reporting;
#'                \item \emph{INDI} =  Reasons for use;
#'                \item \emph{OUTC} =  Outcomes;
#'                \item \emph{THER} =  Drug regimen information;
#'                \item \emph{DRUG_ATC} =  Suspect and  concomitant drugs (ATC);
#'                \item \emph{DOSES} =  Dosage information;
#'                \item \emph{DRUG_SUPP} =  Dechallenge, Rechallenge, route, form;
#'                \item \emph{DRUG_NAME} =  Suspect and concomitant drugs (raw terms);
#'                }
#' @param quarter The quarter from which to import the data.
#'                For updated analyses use last quarterly update,
#'                in the format \emph{23Q1}.
#' @param pids Optional vector of primary IDs to subset the imported data.
#'             Defaults to the entire population.
#' @return A data.table containing the imported data.
#'
#' @examples
#' \dontrun{
#' # Import full DRUG dataset up to 23Q1
#' import("DRUG", "23Q1")
#'
#' # Import reac data for specific primary IDs in quarters up to 23Q1
#' import("REAC", "23Q1", pids = c("pid1", "pid2"))
#' }
#'
#' @export
#'

import <- function(df_name, quarter, pids = NA) {
  path <- paste0(here(), "/data/", quarter, "/", df_name, ".rds")
  if (!file.exists(path)) {
    stop("The dataset specified does not exist")
  } else {
    t <- setDT(readRDS(path))
    if (sum(!is.na(pids)) > 0) {
      t <- t[primaryid %in% pids]
    }
    assign(str_to_title(df_name), t, envir = .GlobalEnv)
  }
  t
}

#' Import MedDRA Data
#'
#' This function imports MedDRA (Medical Dictionary for Regulatory Activities) data from a CSV file and stores it in the global environment.
#'
#' @return A data table containing MedDRA data.
#'
#' @details
#' This function reads MedDRA data from a CSV file located at the path specified by `here()/external_sources/meddra_primary.csv`.
#' If the file does not exist, it will stop execution and provide instructions on how to obtain MedDRA data.
#' If the file exists, it will load the data, select specific columns (def, soc, hlgt, hlt, pt), remove duplicates, and store it in the global environment as "MedDRA".
#'
#' @seealso
#' You can find more information and instructions for obtaining MedDRA data at https://github.com/fusarolimichele/DiAna.
#'
#' @examples
#' \dontrun{
#' # Import MedDRA data
#' import_MedDRA()
#' }
#'
#' @export

import_MedDRA <- function() {
  path <- paste0(here(), "/external_sources/meddra_primary.csv")
  if (!file.exists(path)) {
    stop("The MedDRA is not available with DiAna since the subscription must be done with MEDDRA MSSO.
         Once MedDRA is downloaded, you can use the steps provided in https://github.com/fusarolimichele/DiAna
         to make it ready for download.")
  } else {
    MedDRA <- setDT(
      read_delim(path,
        ";",
        escape_double = FALSE, trim_ws = TRUE
      )
    )[, .(def, soc, hlgt, hlt, pt)] %>% distinct()
    assign("MedDRA", MedDRA, envir = .GlobalEnv)
  }
  MedDRA
}

#' Import ATC classification
#'
#' This function reads the ATC (Anatomical Therapeutic Chemical) classification
#' from an external source and assigns it to a global environment variable.
#'
#' @return A data frame containing the dataset for ATC linkage.
#'
#' @examples
#' \dontrun{
#' import_ATC()
#' }
#'
#' @export
import_ATC <- function() {
  ATC <- setDT(
    read_delim(paste0(here(), "/external_sources/ATC_DiAna.csv"),
      ";",
      escape_double = FALSE, trim_ws = TRUE
    )
  )[, .(
    substance = Substance, code, primary_code, Lvl4, Class4, Lvl3, Class3,
    Lvl2, Class2, Lvl1, Class1
  )] %>% distinct()
  assign("ATC", ATC, envir = .GlobalEnv)
  ATC
}

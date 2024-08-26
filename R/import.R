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
#'                \item \emph{DOSES} =  Dosage information;
#'                \item \emph{DRUG_SUPP} =  Dechallenge, Rechallenge, route, form;
#'                \item \emph{DRUG_NAME} =  Suspect and concomitant drugs (raw terms);
#'                }
#' @param quarter The quarter from which to import the data.
#'                For updated analyses use last quarterly update,
#'                in the format \emph{23Q1}. Defaults to the value assigned to FAERS_version.
#' @param pids Optional vector of primary IDs to subset the imported data.
#'             Defaults to the entire population.
#' @param save_in_environment is a parameter automatically used within functions to avoid that the imported databases are overscribed.
#' @param env The environment where the data will be assigned. Default to .GlobalEnv
#' @return A data.table containing the imported data.
#' @importFrom stringr str_to_title
#' @importFrom here here
#' @examples
#' \dontrun{
#' # This example requires that setup_DiAna has been run to download data
#' FAERS_version <- "24Q1"
#' import("DRUG")
#' }
#'
#' @export
#'

import <- function(df_name, quarter = FAERS_version, pids = NA, save_in_environment = TRUE, env = .GlobalEnv) {
  path <- paste0(here::here(), "/data/", quarter, "/", df_name, ".rds")
  if (!file.exists(path)) {
    stop("The dataset specified does not exist")
  } else {
    t <- setDT(readRDS(path))
    if (sum(!is.na(pids)) > 0) {
      t <- t[primaryid %in% pids]
    }
    if (save_in_environment) {
      assign(stringr::str_to_title(df_name), t, envir = env)
    }
  }
  t
}

#' Import MedDRA Data
#'
#' This function imports MedDRA (Medical Dictionary for Regulatory Activities) data from a CSV file and stores it in the global environment.
#'
#' @inheritParams import
#' @return A data table containing MedDRA data.
#' @importFrom dplyr distinct
#' @importFrom here here
#' @importFrom readr read_delim
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
#' # This example requires a specific file that can only be available with a MeDRA subscription.
#' import_MedDRA()
#' }
#'
#' @export

import_MedDRA <- function(env = .GlobalEnv) {
  path <- paste0(here::here(), "/external_sources/meddra_primary.csv")
  if (!file.exists(path)) {
    stop("The MedDRA is not available with DiAna since the subscription must be done with MEDDRA MSSO.
         Once MedDRA is downloaded, you can use the steps provided in https://github.com/fusarolimichele/DiAna
         to make it ready for download.")
  } else {
    suppressMessages(MedDRA <- setDT(
      readr::read_delim(path,
        ";",
        escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE
      )
    )[, .(def, soc, hlgt, hlt, pt)] %>% dplyr::distinct())
    assign("MedDRA", MedDRA, envir = env)
  }
  MedDRA
}

#' Import ATC classification
#'
#' This function reads the ATC (Anatomical Therapeutic Chemical) classification
#' from an external source and assigns it to a global environment variable.
#' @param primary Whether only the primary ATC should be retrieved.
#' @inheritParams import
#' @return A data frame containing the dataset for ATC linkage.
#' @importFrom dplyr distinct
#' @importFrom here here
#' @importFrom readr read_delim
#'
#' @examples
#' \dontrun{
#' # This example requires that setup_DiAna has been run to download data
#' import_ATC()
#' }
#'
#' @export
import_ATC <- function(primary = T, env = .GlobalEnv) {
  path <- paste0(here::here(), "/external_sources/ATC_DiAna.csv")
  if (!file.exists(path)) {
    stop("The ATC cannot be found in external sources. It should have been downloaded with setup_diana. Please investigate the problem.")
  } else {
    suppressMessages(ATC <- setDT(
      readr::read_delim(path,
        show_col_types = FALSE, ";", escape_double = FALSE, trim_ws = TRUE
      )
    )[, .(
      substance = Substance, code, primary_code, Lvl4, Class4, Lvl3, Class3,
      Lvl2, Class2, Lvl1, Class1
    )] %>% dplyr::distinct())
    if (primary == T) {
      ATC <- ATC[code == primary_code]
    }
    assign("ATC", ATC, envir = env)
    ATC
  }
}

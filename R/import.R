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
#' @param save_in_environment Whether to also assign the table, named in title case
#'   (e.g. `Drug` for `"DRUG"`), in `env`. Default `TRUE`. Use `FALSE` to only
#'   return it, e.g. `my_drug <- import("DRUG", save_in_environment = FALSE)`.
#' @param env The environment where the table is assigned. Defaults to the
#'   environment `import()` is called from: your workspace when called from the
#'   console or a script, or the calling function's own environment when
#'   called inside a function.
#' @return The imported data.table (invisibly when it is also assigned).
#' @importFrom here here
#' @examples
#' # This example requires that setup_DiAna has been run to download data
#' if (file.exists(file.path(here::here(), "data", "24Q1", "DRUG.rds"))) {
#'   import("DRUG", quarter = "24Q1")
#' }
#'
#' @export
#'

import <- function(df_name, quarter = FAERS_version, pids = NA, save_in_environment = TRUE, env = parent.frame()) {
  check_workspace_defaults("quarter")
  path <- file.path(diana_root(), "data", quarter, paste0(df_name, ".rds"))
  if (!file.exists(path)) {
    stop("The dataset ", path, " does not exist. Check `df_name` and `quarter`, ",
      "and download the data with setup_DiAna(\"", quarter, "\") if needed.",
      call. = FALSE
    )
  }
  t <- setDT(readRDS(path))
  if (sum(!is.na(pids)) > 0) {
    t <- t[primaryid %in% pids]
  }
  if (save_in_environment) {
    # e.g. "DRUG_NAME" is assigned as Drug_name
    assign(paste0(substr(df_name, 1, 1), tolower(substring(df_name, 2))), t, envir = env)
    return(invisible(t))
  }
  t
}

#' Import MedDRA Data
#'
#' This function imports MedDRA (Medical Dictionary for Regulatory Activities) data from a CSV file and assigns it as `MedDRA` in `env`.
#'
#' @inheritParams import
#' @return A data table containing MedDRA data.
#' @importFrom dplyr distinct
#' @importFrom here here
#' @importFrom readr read_delim
#' @details
#' This function reads MedDRA data from a CSV file located at the path specified by `here()/external_sources/meddra_primary.csv`.
#' If the file does not exist, it will stop execution and provide instructions on how to obtain MedDRA data.
#' If the file exists, it will load the data, select specific columns (def, soc, hlgt, hlt, pt), remove duplicates, and assign it as `MedDRA` in `env` (by default, the environment it is called from).
#'
#' @seealso
#' You can find more information and instructions for obtaining MedDRA data at https://github.com/fusarolimichele/DiAna_cleaning.
#'
#' @examples
#' # This example requires a specific file that can only be available with a MeDRA subscription.
#' if (file.exists(file.path(here::here(), "external_sources", "meddra_primary.csv"))) {
#'   import_MedDRA()
#' }
#'
#' @export

import_MedDRA <- function(env = parent.frame()) {
  path <- file.path(diana_root(), "external_sources", "meddra_primary.csv")
  if (!file.exists(path)) {
    stop("The MedDRA is not available with DiAna since the subscription must be done with MEDDRA MSSO.
         Once MedDRA is downloaded, you can use the steps provided in https://github.com/fusarolimichele/DiAna_cleaning
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
  invisible(MedDRA)
}

#' Import ATC classification
#'
#' This function reads the ATC (Anatomical Therapeutic Chemical) classification
#' from an external source and assigns it as `ATC` in `env` (by default, the
#' environment it is called from).
#' @param primary Whether only the primary ATC should be retrieved.
#' @inheritParams import
#' @return A data frame containing the dataset for ATC linkage.
#' @importFrom dplyr distinct
#' @importFrom here here
#' @importFrom readr read_delim
#'
#' @examples
#' if (file.exists(file.path(here::here(), "external_sources", "ATC_DiAna.csv"))) {
#'   import_ATC()
#' }
#' @export
import_ATC <- function(primary = TRUE, env = parent.frame()) {
  path <- file.path(diana_root(), "external_sources", "ATC_DiAna.csv")
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
    if (isTRUE(primary)) {
      ATC <- ATC[code == primary_code]
    }
    assign("ATC", ATC, envir = env)
    invisible(ATC)
  }
}

#' Extract Standardised MedDRA Queries (SMQs)
#'
#' This function extracts and organizes Standardised MedDRA Queries (SMQs) from an external CSV file.
#' The function categorizes SMQs into different levels and provides either a "Narrow" scope or all available terms.
#'
#' @param Narrow Logical, default is `TRUE`. If `TRUE`, only the "Narrow" scope SMQs are returned.
#' If `FALSE`, all SMQs are included.
#'
#' @return A named list where each element corresponds to an SMQ group. The names represent the SMQ category,
#' and the values are character vectors of Preferred Terms (PTs) associated with that SMQ.
#'
#' @details
#' The function reads the SMQ dictionary from `external_sources/smq_dictionary.csv`.
#' SMQs are part of MedDRA, which requires a subscription from MedDRA MSSO,
#' so DiAna cannot distribute this file. Prepare it from your MedDRA release
#' as a semicolon-separated file with the columns:
#' \itemize{
#'   \item `SMQ_1` to `SMQ_5`: the SMQ the term belongs to, at each level of
#'     the SMQ hierarchy (level 1 being the broadest);
#'   \item `pt`: the Preferred Term, in lowercase as in DiAna's `Reac`;
#'   \item `NB`: the scope of the term in the SMQ, `"Narrow"` or `"Broad"`.
#' }
#'
#' The function processes five hierarchical levels (`SMQ_1` to `SMQ_5`) and assigns Preferred Terms (PTs)
#' accordingly, filtering by "Narrow" scope if requested.
#'
#' @note If the required SMQ dictionary file is missing, the function stops execution and returns an error message.
#'
#' @examples
#' # Requires an SMQ dictionary prepared from a MedDRA subscription
#' if (file.exists(file.path(here::here(), "external_sources", "smq_dictionary.csv"))) {
#'   smq_list <- extractSMQ(Narrow = TRUE)
#'   smq_list <- extractSMQ(Narrow = FALSE)
#' }
#'
#' @export
extractSMQ <- function(Narrow = TRUE) {
  path <- file.path(diana_root(), "external_sources", "smq_dictionary.csv")
  if (!file.exists(path)) {
    stop("The SMQ dictionary was not found at ", path, ". ",
      "DiAna cannot distribute it, because SMQs are part of MedDRA, which requires a subscription. ",
      "Prepare it from your MedDRA release as a semicolon-separated file with the columns ",
      "SMQ_1 to SMQ_5, pt and NB (\"Narrow\" or \"Broad\"): see ?extractSMQ.",
      call. = FALSE
    )
  }
  smq_dictionary <- setDT(readr::read_delim(path,
    delim = ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE
  ))
  check_columns(smq_dictionary, c(paste0("SMQ_", 1:5), "pt", "NB"), "smq_dictionary.csv")
  # SMQs are listed from the whole dictionary; with Narrow = TRUE only their
  # narrow-scope terms are kept (an SMQ with only broad terms is then empty)
  terms <- if (Narrow) smq_dictionary[NB == "Narrow"] else smq_dictionary
  # one element per SMQ, at every level of the hierarchy; an SMQ that also
  # appears at the level above is listed only once. Empty levels (NA) are
  # not SMQs and are skipped.
  smq_list <- list()
  previous <- character(0)
  for (level in paste0("SMQ_", 1:5)) {
    smqs <- unique(smq_dictionary[[level]])
    for (n in setdiff(smqs[!is.na(smqs)], previous)) {
      smq_list[[n]] <- terms[terms[[level]] %in% n]$pt
    }
    previous <- smqs
  }
  return(smq_list)
}

#' @title import
#' @name import
#'
#' @description
#' Imports one of the FAERS relational databases.
#'
#' @param df_name one of the following:
#'       \itemize{
#'                \item \emph{DRUG} =  Suspect and concomitant drugs (active ingredient);
#'                \item \emph{REAC} =  Suspect reactions (MedDRA PT);
#'                \item \emph{DEMO} =  Demographics and Reporting;
#'                \item \emph{DEMO_SUPP} =  Demographics and Reporting;
#'                \item \emph{INDI} =  Reasons for use;
#'                \item \emph{OUTC} =  Outcomes;
#'                \item \emph{THER} =  Drug regimen information;
#'                \item \emph{DRUG_ATC} =  Suspect and  concomitant drugs (ATC);
#'                \item \emph{Doses} =  Dosage information;
#'                \item \emph{DRUG_SUPP} =  Dechallenge, Rechallenge, route, form;
#'                \item \emph{DRUG_NAME} =  Suspect and concomitant drugs (raw terms);
#'                }
#' @param quarter last quarterly update, in the format \emph{23q1}.
#' @param pids list of specific primaryids that should be imported,
#'             defaults to the entire population.
#' @return It returns the relational database chosen, updated to the specified
#'         quarter, restricted to the specified primaryids.
#'
#' @examples
#' \dontrun{
#' Drug <- import("DRUG", quarter = "23Q1")
#' }
#'
#' @export
#'
import <- function(df_name, quarter, pids = NA) {
  path <- paste0(here(), "/data/", quarter, "/", df_name, ".rds")
  if (file.exists(path)) {
    t <- setDT(readRDS())
    if (sum(!is.na(pids)) > 0) {
      if ("primaryid" %in% colnames(t)) {
        t <- t[primaryid %in% pids]
      } else {
        stop("Column 'primaryid' not found in the data table.")
      }
    }
    return(t)
  } else {
    cat("the dataset specified does not exist")
  }
}

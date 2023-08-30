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
#'                \item \emph{Doses} =  Dosage information;
#'                \item \emph{DRUG_SUPP} =  Dechallenge, Rechallenge, route, form;
#'                \item \emph{DRUG_NAME} =  Suspect and concomitant drugs (raw terms);
#'                }
#' @param quarter The quarter from which to import the data.
#'                For updated analyses use last quarterly update,
#'                in the format \emph{23q1}.
#' @param pids Optional vector of primary IDs to subset the imported data.
#'             Defaults to the entire population.
#' @return A data.table containing the imported data.
#'
#' @examples
#' \dontrun{
#' # Import full DRUG dataset up to 23Q1
#' Drug <- import("DRUG", "23Q1")
#'
#' # Import reac data for specific primary IDs in quarters up to 23Q1
#' selected_Reac <- import("REAC", "23Q1", pids = c("pid1", "pid2"))
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
    return(t)
  }
}

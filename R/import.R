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
#'                \item \emph{INDI} =  Reasons for use;
#'                \item \emph{OUTC} =  Outcomes;
#'                \item \emph{THER} =  Drug regimen information;
#'                \item \emph{DRUG_ATC} =  Suspect and  concomitant drugs (ATC);
#'                \item \emph{DRUG_INFO_Doses} =  Dosage information;
#'                \item \emph{DRUG_INFO_DRroute} =  Dechallenge, Rechallenge, route, form;
#'                \item \emph{DRUG_NAME} =  Suspect and concomitant drugs (raw terms);
#'                \item \emph{REAC_rec} =  Which event reappeared at the rechallenge.
#'                }
#' @param quarter last quarterly update, in the format \emph{23q1}.
#' @param pids list of specific primaryids that should be imported,
#'             defaults to the entire population.
#' @param path path_substring to allow the use of the function
#'             in any operative system. Defaults to \emph{~/}
#' @return It returns the relational database chosen, updated to the specified
#'         quarter, restricted to the specified primaryids.
#'
#' @examples
#' \donttest{Drug <- import("DRUG", quarter = "23Q1")}
#'
#' @export
#'
import <- function(df_name, quarter, pids=NA, path="~/") {
  t <- setDT(readRDS(
    paste0(path,"Desktop/DIANA-on-FAERS/DIANA/data",quarter,"/",df_name,".rds"))
  )
  if(!is.na(pids)) {
    t <- t[primaryid%in%pids]
  }
  return(t)
}

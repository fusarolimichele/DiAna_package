#' Reporting rates of events or substances
#'
#' counts the occurrences of reactions/indications/substance
#' for a given set of primary IDs.
#' Calculates % as the proportion of individuals recording the event.
#'
#' @param pids_cases Vector of primary IDs to consider for counting reactions.
#' @param entity Entity investigated. It can be one of the following:
#'       \itemize{
#'                \item \emph{reaction};
#'                \item \emph{indication};
#'                \item \emph{substance}.
#'                }
#' @param level The desired MedDRA or ATC level for counting (default is "pt").
#'
#' @return A data.table containing counts and percentages of the investigated entity
#'         at the specified level and in descending order.
#'
#' @import tidyverse
#'
#' @export
#'
#' @examples
#' \dontrun{
#' reporting_rates(pids, "reaction", "hlt")
#' reporting_rates(pids, "indication", "pt")
#' reporting_rates(pids, entity = "substance", level = "Class3")
#' }
reporting_rates <- function(pids_cases, entity = "reaction", level = "pt") {
  if (entity == "reaction") {
    df <- Reac
  } else if (entity == "indication") {
    df <- Indi[, .(primaryid, pt = indi_pt)][!pt %in% c("product used for unknown indication", "therapeutic procedures nec", "therapeutic procedures and supportive care nec")]
  } else if (entity == "substance") {
    df <- Drug
  }
  temp <- df[primaryid %in% pids_cases]
  if (level %in% c("hlt", "hlgt", "soc")) {
    import_MedDRA()
    temp <- distinct(distinct(MedDRA[, c("pt", level), with = FALSE])[
      temp,
      on = "pt"
    ][
      , c("primaryid", level),
      with = FALSE
    ])
  }
  if (entity == "substance" & level == "pt") {
    level <- "substance"
  }
  if (entity == "substance" & level %in% c("Class1", "Class2", "Class3", "Class4")) {
    import_ATC()[code == primary_code]
    temp <- distinct(distinct(ATC[, c("substance", level), with = FALSE])[
      temp,
      on = "substance"
    ][
      , c("primaryid", level),
      with = FALSE
    ])
  }
  temp <- temp[, .N, by = get(level)][order(-N)][, perc := N / length(unique(df$primaryid))]
  colnames(temp) <- c(level, "N", "perc")
  temp <- temp[, label := paste0(get(level), " (", round(perc * 100, 2), "%) [", N, "]")]
  temp <- temp[, .(get(level), label, N)]
  if (level != "substance") {
    temp[is.na(V1)]$label <- NA
  }
  colnames(temp) <- c(
    level, paste0("label_", level),
    paste0("N_", level)
  )
  return(temp)
}

#' Generate Hierarchy of events or substances
#'
#' This function generates a hierarchy of reporting rates
#' for a specified entity and based on different MedDRA or ATC levels
#' and writes the result to a xlsx file.
#'
#' @param pids_cases Vector of primary IDs identifying the sample of interest.
#' @param entity Entity investigated. It can be one of the following:
#'       \itemize{
#'                \item \emph{reaction};
#'                \item \emph{indication};
#'                \item \emph{substance}.
#'                }
#' @param file_name Path to save the XLSX file containing the hierarchy.
#'
#' @return None. The function generates and writes the hierarchy to the xlsx.
#'         For indications and reactions, SOCs are ordered by occurrences and, within, HLGTs, HLTs, PTs.
#'         For substances, the ATC hierarchy is followed.
#' @export
#'
#' @examples
#' \dontrun{
#' hierarchycal_rates(pids, "reaction", "reactions_rates.xlsx")
#' hierarchycal_rates(pids, "indication", "indications_rates.xlsx")
#' hierarchycal_rates(pids, "substance", "substances_rates.xlsx")
#' }
hierarchycal_rates <- function(pids_cases, entity = "reaction", file_name = "reporting_rates.xlsx") {
  if (entity %in% c("reaction", "indication")) {
    pts <- reporting_rates(pids_cases, entity = entity, "pt")
    hlts <- reporting_rates(pids_cases, entity = entity, "hlt")
    hlgts <- reporting_rates(pids_cases, entity = entity, "hlgt")
    socs <- reporting_rates(pids_cases, entity = entity, "soc")
    temp <- MedDRA[socs, on = "soc"][hlgts, on = "hlgt"][hlts, on = "hlt"][pts, on = "pt"]
    temp <- temp[order(-N_soc, -label_soc, -N_hlgt, -label_hlgt, -N_hlt, -label_hlt, -N_pt)][
      , .(label_soc, label_hlgt, label_hlt, label_pt)
    ]
  }
  if (entity == "substance") {
    substances <- reporting_rates(pids_cases, entity = entity, "substance")
    Class4s <- reporting_rates(pids_cases, entity = entity, "Class4")
    Class3s <- reporting_rates(pids_cases, entity = entity, "Class3")
    Class2s <- reporting_rates(pids_cases, entity = entity, "Class2")
    Class1s <- reporting_rates(pids_cases, entity = entity, "Class1")
    temp <- ATC[Class1s, on = "Class1"][Class2s, on = "Class2"][Class3s, on = "Class3"][Class4s, on = "Class4"][substances, on = "substance"]
    temp <- temp[order(-N_Class1, -label_Class1, -N_Class2, -label_Class2, -N_Class3, -label_Class3, -N_Class4, -label_Class4, -N_substance)][
      , .(label_Class1, label_Class2, label_Class3, label_Class4, label_substance)
    ]
  }
  writexl::write_xlsx(temp, file_name)
}

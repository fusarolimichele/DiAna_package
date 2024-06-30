#' Reporting rates of events or substances
#'
#' counts the occurrences of reactions/indications/substance
#' for a given set of primary IDs.
#' Calculates % as the proportion of individuals recording the event.
#'
#' @inheritParams descriptive
#' @param pids_cases Vector of primary IDs to consider for counting reactions.
#' @param entity Entity investigated. It can be one of the following:
#'       \itemize{
#'                \item \emph{reaction};
#'                \item \emph{indication};
#'                \item \emph{substance}.
#'                }
#' @param level The desired MedDRA or ATC level for counting (default is "pt").
#'
#' @param drug_role is only used for substances. By default both suspect and concomitant drugs are included.
#'
#' @param drug_indi is only used for indications. By default the indications of all the drugs of the selected primaryids are considered, but you can specify a vector of drugs.
#'
#' @return A data.table containing counts and percentages of the investigated entity
#'         at the specified level and in descending order.
#'
#' @importFrom dplyr distinct
#'
#' @export
#'
#' @examples
#' \dontrun{
#' reporting_rates(pids, "reaction", "hlt")
#' reporting_rates(pids, "indication", "pt")
#' reporting_rates(pids, entity = "substance", level = "Class3")
#' }
reporting_rates <- function(pids_cases, entity = "reaction", level = "pt", drug_role = c("PS", "SS", "I", "C"), drug_indi = NA, temp_reac=Reac,temp_drug=Drug,temp_indi=Indi) {
  if (entity == "reaction") {
    temp <- temp_reac
  } else if (entity == "indication") {
    temp <- temp_indi
    if (sum(!is.na(drug_indi)) > 0) {
      temp <- temp_drug[
        temp,
        on = c("primaryid", "drug_seq")
      ][substance %in% drug_indi]
    }
    temp <- temp[, .(primaryid, pt = indi_pt)][!pt %in% c(
      "product used for unknown indication",
      "therapeutic procedures nec",
      "therapeutic procedures and supportive care nec"
    )]
  } else if (entity == "substance") {
    temp <- dplyr::distinct(temp_drug)[
      role_cod %in% drug_role
    ][, .(primaryid, substance)]
  }
  if (level %in% c("hlt", "hlgt", "soc")) {
    import_MedDRA()
    temp <- dplyr::distinct(dplyr::distinct(MedDRA[, c("pt", level), with = FALSE])[
      temp,
      on = "pt"
    ][
      , c("primaryid", level),
      with = FALSE
    ])
  }
  if (entity == "substance") {
    if (level == "pt") {
      level <- "substance"
    } else if (level %in% c("Class1", "Class2", "Class3", "Class4")) {
      import_ATC()[code == primary_code]
      temp <- dplyr::distinct(dplyr::distinct(ATC[, c("substance", level), with = FALSE])[
        temp,
        on = "substance"
      ][
        , c("primaryid", level),
        with = FALSE
      ])
    }
  }
  temp <- dplyr::distinct(temp)[, .N, by = get(level)][order(-N)][, perc := N / length(unique(temp$primaryid))]
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
#' @param drug_role If entity is substance, it is possible to specify the drug roles that should be considered
#'
#' @return None. The function generates and writes the hierarchy to the xlsx.
#'         For indications and reactions, SOCs are ordered by occurrences and, within, HLGTs, HLTs, PTs.
#'         For substances, the ATC hierarchy is followed.
#' @importFrom writexl write_xlsx
#' @export
#'
#' @examples
#' \dontrun{
#' hierarchycal_rates(pids, "reaction", "reactions_rates.xlsx")
#' hierarchycal_rates(pids, "indication", "indications_rates.xlsx")
#' hierarchycal_rates(pids, "substance", "substances_rates.xlsx")
#' }
hierarchycal_rates <- function(pids_cases, entity = "reaction", file_name = paste0(project_path, "reporting_rates.xlsx"), drug_role = c("PS", "SS", "I", "C")) {
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
    substances <- reporting_rates(pids_cases, entity = entity, "substance", drug_role = drug_role)
    Class4s <- reporting_rates(pids_cases, entity = entity, "Class4", drug_role = drug_role)
    Class3s <- reporting_rates(pids_cases, entity = entity, "Class3", drug_role = drug_role)
    Class2s <- reporting_rates(pids_cases, entity = entity, "Class2", drug_role = drug_role)
    Class1s <- reporting_rates(pids_cases, entity = entity, "Class1", drug_role = drug_role)
    temp <- ATC[Class1s, on = "Class1"][Class2s, on = "Class2"][Class3s, on = "Class3"][Class4s, on = "Class4"][substances, on = "substance"]
    temp <- temp[order(-N_Class1, -label_Class1, -N_Class2, -label_Class2, -N_Class3, -label_Class3, -N_Class4, -label_Class4, -N_substance)][
      , .(label_Class1, label_Class2, label_Class3, label_Class4, label_substance)
    ]
  }
  writexl::write_xlsx(temp, file_name)
}

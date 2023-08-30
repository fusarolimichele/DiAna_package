#' Count Reactions by MedDRA Level
#'
#' counts the occurrences of reactions based on MedDRA levels
#' for a given set of primary IDs.
#' Calculates % as the proportion of individuals recording the event.
#'
#' @param pids_cases Vector of primary IDs to consider for counting reactions.
#' @param meddra_level The desired MedDRA level for counting (default is "pt").
#'
#' @return A data.table containing counts and percentages of reactions
#'         at the specified MedDRA level and in descending order.
#' @export
#'
#' @examples
#' \dontrun{
#' count_reactions(pids_cases, "pt")
#' }
count_reactions <- function(pids_cases, meddra_level = "pt") {
  temp <- Reac[primaryid %in% pids_cases]
  if (meddra_level != "pt") {
    temp <- distinct(MedDRA[, c("pt", meddra_level), with = FALSE])[temp, on = "pt"]
  }
  temp <- temp[, .N, by = get(meddra_level)][order(-N)][, perc := N / length(pids_cases)]
  colnames(temp) <- c(meddra_level, "N", "perc")
  temp <- temp[, label := paste0(get(meddra_level), " (", round(perc * 100, 2), "%) [", N, "]")]
  temp <- temp[, .(get(meddra_level), label, N)]
  colnames(temp) <- c(
    meddra_level, paste0("label_", meddra_level),
    paste0("N_", meddra_level)
  )
  return(temp)
}
#' Generate Hierarchy of Reactions
#'
#' This function generates a hierarchy of reactions
#' based on different MedDRA levels
#' and writes the result to a CSV file.
#'
#' @param pids_cases Vector of primary IDs identifying the sample of interest.
#' @param reactions_path Path to save the CSV file containing the hierarchy.
#'
#' @return None. The function generates and writes the hierarchy to the csv.
#'         SOCs are ordered by occurrences and, within, HLGTs, HLTs, PTs.
#' @export
#'
#' @examples
#' \dontrun{
#' hierarchy_reactions(pids_cases, "reactions_list.csv")
#' }
hierarchy_reactions <- function(pids_cases, reactions_path) {
  pts <- count_reactions(pids_cases, "pt")
  hlts <- count_reactions(pids_cases, "hlt")
  hlgts <- count_reactions(pids_cases, "hlgt")
  socs <- count_reactions(pids_cases, "soc")
  temp <- MedDRA[socs, on = "soc"][hlgts, on = "hlgt"][hlts, on = "hlt"][pts, on = "pt"]
  temp <- temp[order(-N_soc, -N_hlgt, -N_hlt, -N_pt)][
    , .(label_soc, label_hlgt, label_hlt, label_pt)
  ]
  write.csv2(temp, reactions_path)
}

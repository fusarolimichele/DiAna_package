#' count_reactions
#' Count the occurrences of each event (at any meddra level)
#' and % as the number of individuals in the sample recording the event.
#'
#' @param pids_cases the primaryids identifying the sample
#' @param meddra_level meddra_level investigated
#'
#' @return a database with three columns: event, N, and % in descending order.
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

#' hierarchy_reactions
#' Count the occurrences of each event (at all the meddra level) and provides
#' a hierarchical csv.
#' @param pids_cases the primaryids identifying the sample
#' @param reactions_path the path for storing the csv.
#' @return csv with SOCs ordered by occurrences and, within, HLGTs, HLTs, PTs.
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

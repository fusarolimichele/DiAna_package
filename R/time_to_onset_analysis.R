#' Perform time-to-onset analysis for drug-event associations
#'
#' This function conducts a time-to-onset analysis for associations between drugs and events based on user-specified parameters.
#' @param drug_selected A list of drugs for analysis. Can be a list of lists (to collapse terms together) if drug_level is set to custom.
#' @param reac_selected A list of adverse events for analysis. Can be a list of lists (to collapse terms together) if meddra_level is set to custom.
#' @param temp_d Data table containing drug data (default is Drug). If set to Drug[role_cod %in% c("PS","SS")] allows to investigate only suspects.
#' @param temp_r Data table containing reaction data (default is Reac).
#' @param meddra_level The desired MedDRA level for analysis (default is "pt"). If set to "custom" allows a list of lists for reac_selected (collapsing multiple terms).
#' @param drug_level The desired drug level for analysis (default is "substance"). If set to "custom" allows a list of lists for reac_selected (collapsing multiple terms).
#' @param restriction Primary IDs to consider for analysis (default is "none", which includes the entire population). If set to Demo[!RB_duplicates_only_susp]$primaryid, for example, allows to exclude duplicates according to one of the deduplication algorithms.
#' @param minimum_cases The minimum number of cases required for the analysis (default is 3).
#' @param max_TTO The maximum time to onset considered in the analysis, in days (default is 365).
#'
#' @return A data.table containing results of the time-to-onset analysis, including drug-event associations, KS test statistics, and p-values.
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' df <- time_to_onset_analysis("aripiprazole", "gambling")
#' df1 <- time_to_onset_analysis(c("aripiprazole", "pramipexole"), c("gambling", "gambling disorder"))
#' df2 <- time_to_onset_analysis(c("aripiprazole", "pramipexole"),
#'   list(
#'     "gambling_PT" = c("gambling"),
#'     "gambling_disorder_PT" = c("gambling disorder"),
#'     "gambling_query" = c("gambling", "gambling disorder")
#'   ),
#'   temp_d = Drug[role_cod %in% c("PS", "SS")],
#'   meddra_level = "custom",
#'   max_TTO = 3 * 365
#' )
#' }
#'
#' @seealso
#' \code{\link{ks.test}} for information about the Kolmogorov-Smirnov test.
#'
#' #' @references
#' Van Holle, L., Zeinoun, Z., Bauchau, V. and Verstraeten, T. (2012), Using time-to-onset for detecting safety signals in spontaneous reports of adverse events following immunization: a proof of concept study. Pharmacoepidemiol Drug Saf, 21: 603-610. https://doi.org/10.1002/pds.3226
#'
#'
#' @export
time_to_onset_analysis <- function(
    drug_selected, reac_selected,
    temp_d = Drug, temp_r = Reac,
    meddra_level = "pt",
    drug_level = "substance",
    restriction = "none",
    minimum_cases = 3,
    max_TTO = 365) {
  if (length(restriction) > 1) {
    temp_d <- temp_d[primaryid %in% restriction] %>% droplevels()
    temp_r <- temp_r[primaryid %in% restriction] %>% droplevels()
  }
  ##
  Ther <- import("THER", save_in_environment = FALSE)
  temp_t <- Ther[, .(primaryid, drug_seq, time_to_onset)][
    !is.na(time_to_onset) & time_to_onset >= 0 & time_to_onset <= max_TTO
  ]
  temp_d <- temp_t[
    temp_d[, .(primaryid, substance, drug_seq)],
    on = c("primaryid", "drug_seq")
  ][
    !is.na(time_to_onset)
  ]
  temp_r <- temp_t[ # mean
    , .(time_to_onset = min(time_to_onset)),
    by = "primaryid"
  ][
    temp_r[, c("primaryid", "pt"), with = FALSE],
    on = "primaryid"
  ][
    !is.na(time_to_onset)
  ]
  if (meddra_level != "pt" & meddra_level != "custom") {
    if (!exists("MedDRA")) {
      stop("The MedDRA dictionary is not uploaded.
                                Without it, only analyses at the PT level are possible")
    }
    temp_r <- MedDRA[, c(meddra_level, "pt", "time_to_onset"), with = FALSE][temp_r, on = "pt"]
  }
  if (meddra_level == "custom") {
    df_custom <- data.table(
      custom = rep(names(reac_selected), lengths(reac_selected)),
      pt = unlist(reac_selected)
    )
    temp_r <- df_custom[temp_r, on = "pt", allow.cartesian = TRUE]
    reac_selected <- names(reac_selected)
  }
  if (drug_level == "custom") {
    df_custom <- data.table(
      custom = rep(names(drug_selected), lengths(drug_selected)),
      substance = unlist(drug_selected)
    )
    temp_d <- df_custom[temp_d, on = "substance", allow.cartesian = TRUE]
    drug_selected <- names(drug_selected)
  }
  #
  temp_d <- temp_d[, c(drug_level, "primaryid", "time_to_onset"), with = FALSE] %>% distinct()
  temp_d <- temp_d[, .(time_to_onset = max(time_to_onset)), by = c(drug_level, "primaryid")]
  temp_r <- temp_r[, c(meddra_level, "primaryid", "time_to_onset"), with = FALSE] %>% distinct()
  temp_r <- temp_r[, .(time_to_onset = min(time_to_onset)), by = c(meddra_level, "primaryid")]


  # TOT <- length(unique(temp_d$primaryid))
  temp_d1 <- temp_d[get(drug_level) %in% drug_selected][, .(primaryid_substance = list(primaryid), ttos = list(time_to_onset)), by = drug_level]
  temp_r1 <- temp_r[get(meddra_level) %in% reac_selected][, .(primaryid_event = list(primaryid), ttos = list(time_to_onset)), by = meddra_level]
  colnames(temp_r1) <- c("event", "primaryid_event", "ttos_event")
  colnames(temp_d1) <- c("substance", "primaryid_substance", "ttos_drug")
  results <- setDT(expand.grid("substance" = unlist(drug_selected), "event" = unlist(reac_selected)))
  results <- results[temp_d1, on = "substance"]
  results <- results[temp_r1, on = "event"]
  # results <- results[, D_E := map2(primaryid_substance, primaryid_event,  \(x, y)length(intersect(x, y)))]
  results <- results[, D_E := map2(primaryid_substance, primaryid_event, \(x, y) x %in% y)]
  results <- results[, D_E := map2(ttos_drug, D_E, \(x, y) x[y])]
  # results <- results[, D_nE := as.numeric(map2(primaryid_substance, primaryid_event, \(x, y)length(setdiff(x, y))))]
  results <- results[, D_nE := map2(primaryid_substance, primaryid_event, \(x, y) !x %in% y)]
  results <- results[, D_nE := map2(ttos_drug, D_nE, \(x, y) x[y])]
  # results <- results[, D := D_E + D_nE]
  # results <- results[, nD_E := as.numeric(map2(primaryid_event, primaryid_substance, \(x, y)length(setdiff(x, y))))]
  # results <- results[, E := D_E + nD_E]
  results <- results[, nD_E := map2(primaryid_event, primaryid_substance, \(x, y) !x %in% y)]
  results <- results[, nD_E := map2(ttos_event, nD_E, \(x, y) x[y])]
  #### Calculate KS
  results <- results[lengths(D_E)>0]
  results <- results[lengths(nD_E)>0]
  results <- results[, ks_event := map2(D_E, nD_E, \(x, y) ks.test(unlist(x), unlist(y),
    alternative = "two.sided", exact = FALSE
  ))]
  results <- results[lengths(D_nE)>0]
  results <- results[, ks_drug := map2(D_E, D_nE, \(x, y) ks.test(unlist(x), unlist(y),
    alternative = "two.sided", exact = FALSE
  ))]
  results <- results[, index := .I]
  results <- results[, D_event := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ks_event[[x]][[1]], NA))]
  results <- results[, p_event := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ks_event[[x]][[2]], NA))]
  results <- results[, D_drug := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ks_drug[[x]][[1]], NA))]
  results <- results[, p_drug := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ks_drug[[x]][[2]], NA))]
  results <- results[, n_cases_with_tto := map2(index, D_E, \(x, y) length(unlist(y)))]
  results <- results[, summary := map2(index, D_E, \(x, y) list(summary(unlist(y))))]
  results <- results[, min := map2(index, D_E, \(x, y) summary(unlist(y))[[1]])]
  results <- results[, Q1 := map2(index, D_E, \(x, y) summary(unlist(y))[[2]])] ## TO DO
  results <- results[, Q2 := map2(index, D_E, \(x, y) summary(unlist(y))[[3]])]
  results <- results[, mean := map2(index, D_E, \(x, y) summary(unlist(y))[[4]])]
  results <- results[, Q3 := map2(index, D_E, \(x, y) summary(unlist(y))[[5]])]
  results <- results[, max := map2(index, D_E, \(x, y) summary(unlist(y))[[6]])]
  return(results)
}

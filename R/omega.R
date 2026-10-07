#' Omega drug-drug interaction analysis on DiAna CDM
#'
#' Computes the Omega interaction measure (Noren et al. 2008) for every
#' combination of a first drug, a second drug and an adverse event, starting
#' from the `Drug` and `Reac` tables of the DiAna CDM. The
#' interface mirrors [DiAna::disproportionality_analysis()] and calls the pvOmega package for the calculation.
#'
#' The 'pvOmega' package is not on CRAN and is needed only by this function.
#' Install it with `remotes::install_github("Uppsala-Monitoring-Centre/pvOmega")`.
#'
#' ## Report universe
#' The total number of reports (`n...`) is the number of distinct
#' `primaryid` in `temp_reac`, intersected with `restriction` when supplied.
#' All drug and event report sets are intersected with this universe, so every
#' count refers to the same population.
#' When both orderings of a drug pair occur (e.g. A-B and B-A), only the first is kept.
#' Omega is symmetric in the two drugs.
#'
#' ## Drug roles
#' By default only drugs recorded as primary suspect, secondary suspect or
#' interacting (`role_cod` in `PS`, `SS`, `I`) count as exposure, following
#' the approach used at Uppsala Monitoring Centre (Hult et al. 2020). The
#' universe is not filtered by role: a report where a drug is only concomitant
#' contributes to the background stratum. Set `temp_drug = Drug` to count all
#' roles.
#'
#' ## Interpretation
#' Omega compares the observed number of reports with the number expected if
#' the two drugs contributed additive, independent risks. `omega_lower > 0`
#' (Omega025 > 0 at the default 95% level) indicates that the combination is
#' reported more often than expected under no interaction. As for any
#' disproportionality measure, this is a hypothesis for clinical review, not
#' evidence of a causal interaction. Always inspect `f00`, `f10`, `f01`, `f11`
#' and `g11` and the case series, alongside Omega, as recommended in the original paper.
#'
#' @family drug-drug interaction functions
#' @param drug1_selected First drug(s). A character vector, or a (named) list
#'   whose elements are character vectors of terms to collapse into one group.
#' @param drug2_selected Second drug(s), same format as `drug1_selected`.
#' @param reac_selected Adverse event(s), same format as `drug1_selected`.
#' @param temp_drug Drug dataset (default `Drug[role_cod%in%c("PS","SS","I")]`, as created by
#'   `DiAna::import("DRUG")`). Can be set to `DiAna::sample_Drug` for testing.
#' @param temp_reac Reac dataset (default `Reac`). Can be set to
#'   `DiAna::sample_Reac` for testing.
#' @param restriction Primary IDs to consider (default `"none"`, the entire
#'   population). For example `Demo[!RB_duplicates_only_susp]$primaryid`
#'   excludes duplicates according to one of DiAna's deduplication algorithms.
#' @param minimum_cases Minimum number of cases (`n111`) to flag a signal
#'   (default 3). With alpha = 0.5, credibility interval 0.95 and the Gamma interval, fewer than 3
#'   cases cannot produce `omega_lower > 0` anyway.
#' @param log2_threshold Threshold on `omega_lower` for flagging a signal
#'   (default 0).
#' @param store_pids Logical. If `TRUE`, adds a list column `pids_cases` with
#'   the primary IDs of the reports listing both drugs and the event, useful
#'   for case-series review. Default `FALSE`.
#' @param save_in_excel Logical. If `TRUE`, writes the results to an Excel
#'   file (requires the 'writexl' package). Default `FALSE`.
#' @param file_name Name of the Excel file (without extension). Only used if
#'   `save_in_excel = TRUE`.
#'
#' @return A `data.table` with one row per drug1-drug2-event combination:
#'   the labels `drug1`, `drug2`, `event`, all columns returned by
#'   `pvOmega::omega_from_counts()`, `label_omega` and `omega_signal` (an ordered
#'   factor: `"not enough cases"`, `"no SDR"`, `"SDR"`).
#'
#' @references
#' Noren GN, Sundberg R, Bate A, Edwards IR. A statistical methodology for
#' drug-drug interaction surveillance. Stat Med. 2008;27(16):3057-70.
#' \doi{10.1002/sim.3247}
#'
#' Hult S, Sartori D, Bergvall T, et al. A feasibility study of drug-drug
#' interaction signal detection in regular pharmacovigilance. Drug Saf.
#' 2020;43:775-85. \doi{10.1007/s40264-020-00939-y}
#'
#' @examples
#' if (requireNamespace("pvOmega", quietly = TRUE)) {
#'   omega_analysis(
#'     drug1_selected = "paracetamol",
#'     drug2_selected = "ibuprofen",
#'     reac_selected = "overdose",
#'     temp_drug = sample_Drug,
#'     temp_reac = sample_Reac
#'   )
#' }
#' @export
omega_analysis <- function(drug1_selected,
                           drug2_selected,
                           reac_selected,
                           temp_drug = Drug[role_cod %in% c("PS", "SS", "I")],
                           temp_reac = Reac,
                           restriction = "none",
                           minimum_cases = 3,
                           log2_threshold = 0,
                           store_pids = FALSE,
                           save_in_excel = FALSE,
                           file_name = "omega_results") {
  # ---- checks ----------------------------------------------------------------
  if (!requireNamespace("pvOmega", quietly = TRUE)) {
    stop("omega_analysis() requires the 'pvOmega' package. Install it with ",
      "remotes::install_github(\"Uppsala-Monitoring-Centre/pvOmega\").",
      call. = FALSE
    )
  }
  check_columns(temp_drug, c("primaryid", "substance"), "temp_drug")
  check_columns(temp_reac, c("primaryid", "pt"), "temp_reac")

  drug1_groups <- as_term_groups(drug1_selected, "drug1_selected")
  drug2_groups <- as_term_groups(drug2_selected, "drug2_selected")
  reac_groups <- as_term_groups(reac_selected, "reac_selected")

  # ---- report universe ---------------------------------------------------------
  universe <- unique(temp_reac[["primaryid"]])
  if (!identical(restriction, "none")) {
    universe <- universe[universe %in% unique(restriction)]
  }
  if (length(universe) == 0L) stop("The report universe is empty.", call. = FALSE)

  # ---- drug and event report sets ------------------------------------------------
  drug_keep <- temp_drug[["primaryid"]] %in% universe
  drug_ids <- temp_drug[["primaryid"]][drug_keep]
  drug_terms <- temp_drug[["substance"]][drug_keep]

  reac_keep <- temp_reac[["primaryid"]] %in% universe
  reac_ids <- temp_reac[["primaryid"]][reac_keep]
  reac_terms <- temp_reac[["pt"]][reac_keep]

  pids_d1 <- pids_by_group(drug_ids, drug_terms, drug1_groups)
  pids_d2 <- pids_by_group(drug_ids, drug_terms, drug2_groups)
  pids_r <- pids_by_group(reac_ids, reac_terms, reac_groups)

  warn_empty(pids_d1, "drug1_selected")
  warn_empty(pids_d2, "drug2_selected")
  warn_empty(pids_r, "reac_selected")

  # ---- combinations ----------------------------------------------------------------
  combos <- expand.grid(
    i = seq_along(drug1_groups),
    j = seq_along(drug2_groups),
    k = seq_along(reac_groups),
    KEEP.OUT.ATTRS = FALSE
  )
  same_drug <- mapply(function(i, j) {
    setequal(drug1_groups[[i]], drug2_groups[[j]])
  }, combos$i, combos$j)
  combos <- combos[!same_drug, , drop = FALSE]

  n1 <- names(drug1_groups)[combos$i]
  n2 <- names(drug2_groups)[combos$j]
  key <- paste(pmin(n1, n2), pmax(n1, n2), combos$k, sep = "\r")
  combos <- combos[!duplicated(key), , drop = FALSE]

  if (nrow(combos) == 0L) {
    stop("No valid drug1-drug2-event combinations (the two drugs must differ).",
      call. = FALSE
    )
  }

  overlap <- mapply(function(i, j) {
    length(intersect(drug1_groups[[i]], drug2_groups[[j]])) > 0L
  }, combos$i, combos$j)
  if (any(overlap)) {
    warning("Some drug1 and drug2 groups share terms; their reports count as ",
      "exposed to both drugs.",
      call. = FALSE
    )
  }

  # ---- counts ----------------------------------------------------------------------
  nc <- nrow(combos)
  n111 <- n11. <- n1.1 <- n.11 <- n1.. <- n.1. <- n..1 <- numeric(nc)
  cases <- vector("list", nc)

  for (row in seq_len(nc)) {
    d1 <- pids_d1[[combos$i[row]]]
    d2 <- pids_d2[[combos$j[row]]]
    r <- pids_r[[combos$k[row]]]
    d12 <- fast_intersect(d1, d2)
    d12r <- fast_intersect(d12, r)
    n111[row] <- length(d12r)
    n11.[row] <- length(d12)
    n1.1[row] <- length(fast_intersect(d1, r))
    n.11[row] <- length(fast_intersect(d2, r))
    n1..[row] <- length(d1)
    n.1.[row] <- length(d2)
    n..1[row] <- length(r)
    if (isTRUE(store_pids)) cases[[row]] <- d12r
  }

  res <- pvOmega::omega_from_counts(
    n111 = n111, n11. = n11., n1.1 = n1.1, n.11 = n.11,
    n1.. = n1.., n.1. = n.1., n..1 = n..1, n... = length(universe),
    alpha1 = 0.5, alpha2 = 0.5, cred_level = 0.95
  )

  res <- cbind(
    data.table::data.table(
      drug1 = names(drug1_groups)[combos$i],
      drug2 = names(drug2_groups)[combos$j],
      event = names(reac_groups)[combos$k]
    ),
    res
  )

  # ---- labels and signals ------------------------------------------------------------
  label <- ifelse(
    is.na(res[["omega"]]),
    NA_character_,
    paste0(
      round(res[["omega"]], 2), " (", round(res[["omega_lower"]], 2), "; ",
      round(res[["omega_upper"]], 2), ") [", res[["n111"]], "]"
    )
  )
  data.table::set(res, j = "label_omega", value = label)
  signal <- ifelse(
    res[["n111"]] < minimum_cases, "not enough cases",
    ifelse(!is.na(res[["omega_lower"]]) & res[["omega_lower"]] > log2_threshold,
      "SDR", "no SDR"
    )
  )
  data.table::set(res,
    j = "omega_signal",
    value = factor(signal,
      levels = c("not enough cases", "no SDR", "SDR"),
      ordered = TRUE
    )
  )
  if (isTRUE(store_pids)) data.table::set(res, j = "pids_cases", value = list(cases))

  if (isTRUE(save_in_excel)) {
    if (!requireNamespace("writexl", quietly = TRUE)) {
      stop("Package 'writexl' is required to save results in Excel.", call. = FALSE)
    }
    to_write <- res[, !vapply(res, is.list, logical(1)), with = FALSE]
    writexl::write_xlsx(to_write, paste0(file_name, ".xlsx"))
  }

  res[]
}

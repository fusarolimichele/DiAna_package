#' Perform Disproportionality Analysis
#'
#' performs disproportionality analysis and returns the results.
#'
#' @param drug_selected A list of drugs for analysis.
#' @param reac_selected A list of adverse events for analysis.
#' @param temp_d Data table containing drug data (default is Drug).
#' @param temp_r Data table containing reaction data (default is Reac).
#' @param meddra_level The desired MedDRA level for analysis (default is "pt").
#' @param restriction Primary IDs to consider for analysis (default is "none").
#' @param sign_ciphers Number of decimal places for calculated values (default is 2).
#' @param threshold_ROR Threshold for calculating Risk Odds Ratio (default is 3).
#' @param threshold_IC Threshold for calculating Information Component (default is 1).
#' @param event_names Event names for labeling results (default is "none").
#' @param KeepLessThanThreshold Keep values less than threshold (default is TRUE).
#' @param order Order for analysis: "reac" or "drug" (default is "reac").
#' @param threshold Threshold for analysis (default is 1).
#'
#' @return A data.table containing disproportionality analysis results.
#'
#'
#' @export
disproportionality_analisis <- function(drug_selected, reac_selected, temp_d = Drug, temp_r = Reac, meddra_level = "pt", restriction = "none", sign_ciphers = 2, threshold_ROR = 3, threshold_IC = 1, event_names = "none", KeepLessThanThreshold = TRUE, order = "reac", threshold = 1) {
  ROR_df <- data.table()
  if (length(restriction) > 1) {
    temp_d <- temp_d[primaryid %in% restriction]
    temp_r <- temp_r[primaryid %in% restriction]
  }
  temp_r <- temp_r[, c(meddra_level, "primaryid"), with = FALSE]
  temp_d <- temp_d[, .(Substance, primaryid)] %>% distinct()
  temp_r <- temp_r %>% distinct()
  TOT <- length(unique(temp_d$primaryid))
  if (order == "reac") {
    for (n in 1:length(reac_selected)) {
      cat(n)
      r <- reac_selected[[n]]
      pids_r <- unique(temp_r[get(meddra_level) %in% r]$primaryid)
      if (isTRUE(KeepLessThanThreshold)) {
        temp_drug_selected <- drug_selected
      } else {
        temp_drug_selected <- distinct(temp_d[primaryid %in% pids_r][, .(Substance, primaryid)])[, .N, by = "Substance"][Substance %in% drug_selected][N >= threshold]$Substance
      }
      for (d in temp_drug_selected) {
        pids_d <- unique(temp_d[Substance %in% d]$primaryid)
        D <- as.numeric(length(pids_d))
        cat(".")
        AE <- as.numeric(length(pids_r))
        D_AE <- as.numeric(length(intersect(pids_d, pids_r)))
        D_nAE <- as.numeric(length(setdiff(pids_d, pids_r)))
        nD_AE <- as.numeric(length(setdiff(pids_r, pids_d)))
        nD_nAE <- as.numeric(TOT - D - nD_AE)
        if (D_AE >= threshold_ROR) {
          (tab <- as.matrix(data.table(AE = c(D_AE, nD_AE), nAE = c(D_nAE, nD_nAE))))
          rownames(tab) <- c("D", "nD")
          or <- odds.ratio(tab)
          ROR <- floor(or$OR * 10^sign_ciphers) / 10^sign_ciphers
          ROR_lower <- floor(or$`2.5 %` * 10^sign_ciphers) / 10^sign_ciphers
          ROR_upper <- floor(or$`97.5 %` * 10^sign_ciphers) / 10^sign_ciphers
          p_value_fisher <- or$p
        } else {
          p_value_fisher <- NA
          ROR <- NA
          ROR_lower <- NA
          ROR_upper <- NA
        }
        if (D_AE >= threshold_IC) {
          IC <- log2((D_AE + .5) / (((D * AE) / TOT) + .5))
          IC_lower <- floor((IC - 3.3 * (D_AE + .5)^(-1 / 2) - 2 * (D_AE + .5)^(-3 / 2)) * 10^sign_ciphers) / 10^sign_ciphers
          IC_upper <- floor((IC + 2.4 * (D_AE + .5)^(-1 / 2) - 0.5 * (D_AE + .5)^(-3 / 2)) * 10^sign_ciphers) / 10^sign_ciphers
          IC <- floor(IC * 10^sign_ciphers) / 10^sign_ciphers
        } else {
          IC <- NA
          IC_lower <- NA
          IC_upper <- NA
        }
        results <-
          data.table(
            drug = paste0(d, collapse = "; "), event = ifelse(event_names == "none", paste0(r, collapse = "; "), event_names[[n]]), ROR = ROR,
            ROR_lower, ROR_upper, p_value_fisher, IC, IC_lower, IC_upper, cases = D_AE,
            Drug_n = D, Event_n = AE, TOT
          )
        ROR_df <- rbindlist(list(ROR_df, results))
      }
    }
  }
  if (order == "drug") {
    for (n in 1:length(drug_selected)) {
      cat(n)
      d <- drug_selected[[n]]
      pids_d <- unique(temp_d[Substance %in% d]$primaryid)
      if (isTRUE(KeepLessThanThreshold)) {
        temp_reac_selected <- reac_selected
      } else {
        temp_reac_selected <- distinct(temp_r[primaryid %in% pids_d][, c(meddra_level, "primaryid"), with = FALSE])[, .N, by = meddra_level][get(meddra_level) %in% unlist(reac_selected)][N >= threshold][, meddra_level, with = FALSE][[meddra_level]]
      }
      for (r in 1:length(temp_reac_selected)) {
        pids_r <- unique(temp_r[get(meddra_level) %in% temp_reac_selected[[r]]]$primaryid)
        D <- as.numeric(length(pids_d))
        cat(".")
        AE <- as.numeric(length(pids_r))
        D_AE <- as.numeric(length(intersect(pids_d, pids_r)))
        D_nAE <- as.numeric(length(setdiff(pids_d, pids_r)))
        nD_AE <- as.numeric(length(setdiff(pids_r, pids_d)))
        nD_nAE <- as.numeric(TOT - D - nD_AE)
        if (D_AE >= threshold_ROR) {
          (tab <- as.matrix(data.table(AE = c(D_AE, nD_AE), nAE = c(D_nAE, nD_nAE))))
          rownames(tab) <- c("D", "nD")
          or <- odds.ratio(tab)
          ROR <- floor(or$OR * 10^sign_ciphers) / 10^sign_ciphers
          ROR_lower <- floor(or$`2.5 %` * 10^sign_ciphers) / 10^sign_ciphers
          ROR_upper <- floor(or$`97.5 %` * 10^sign_ciphers) / 10^sign_ciphers
          p_value_fisher <- or$p
        } else {
          p_value_fisher <- NA
          ROR <- NA
          ROR_lower <- NA
          ROR_upper <- NA
        }
        if (D_AE >= threshold_IC) {
          IC <- log2((D_AE + .5) / (((D * AE) / TOT) + .5))
          IC_lower <- floor((IC - 3.3 * (D_AE + .5)^(-1 / 2) - 2 * (D_AE + .5)^(-3 / 2)) * 10^sign_ciphers) / 10^sign_ciphers
          IC_upper <- floor((IC + 2.4 * (D_AE + .5)^(-1 / 2) - 0.5 * (D_AE + .5)^(-3 / 2)) * 10^sign_ciphers) / 10^sign_ciphers
          IC <- floor(IC * 10^sign_ciphers) / 10^sign_ciphers
        } else {
          IC <- NA
          IC_lower <- NA
          IC_upper <- NA
        }
        results <-
          data.table(
            drug = paste0(d, collapse = "; "), event = ifelse(event_names == "none", paste0(reac_selected[r], collapse = "; "), event_names[[r]]), ROR = ROR,
            ROR_lower, ROR_upper, p_value_fisher, IC, IC_lower, IC_upper, cases = D_AE,
            Drug_n = D, Event_n = AE, TOT
          )
        ROR_df <- rbindlist(list(ROR_df, results))
      }
    }
  }
  ROR_df$label_ROR <- paste0(ROR_df$ROR, " (", ROR_df$ROR_lower, "-", ROR_df$ROR_upper, ") [", ROR_df$cases, "]")
  ROR_df$label_IC <- paste0(ROR_df$IC, " (", ROR_df$IC_lower, "-", ROR_df$IC_upper, ") [", ROR_df$cases, "]")
  ROR_df$Bonferroni <- ROR_df$p_value_fisher < 0.05 / nrow(ROR_df[cases >= threshold_ROR])
  ROR_df$color_ROR <- as.character(NA)
  ROR_df$color_ROR <- ifelse(is.nan(ROR_df$ROR_lower), "all_associated",
    ifelse(ROR_df$ROR_lower <= 1, "no signal",
      ifelse(ROR_df$Bonferroni == FALSE, "light signal",
        "strong signal"
      )
    )
  )
  ROR_df$color_IC <- ifelse(is.nan(ROR_df$IC_lower), "all_associated",
    ifelse(ROR_df$IC_lower <= 0, "no signal",
      "strong signal"
    )
  )
  return(ROR_df)
}

#' Perform Disproportionality Analysis
#'
#' performs disproportionality analysis and returns the results.
#'
#' @param drug_selected A list of drugs for analysis.
#' @param reac_selected A list of adverse events for analysis.
#' @param temp_d Data table containing drug data (default is Drug).
#' @param temp_r Data table containing reaction data (default is Reac).
#' @param meddra_level The desired MedDRA level for analysis (default is "pt").
#' @param restriction Primary IDs to consider for analysis (default is "none",
#'                    which includes the entire population).
#' @param sign_ciphers Number of decimal places for calculated values (default is 2).
#' @param threshold_ROR Threshold for calculating Reporitng Odds Ratio (default is 3).
#' @param threshold_IC Threshold for calculating Information Component (default is 1).
#' @param event_names Event names for labeling results (default is "none").
#' @param KeepLessThanThreshold Keep values less than threshold (default is TRUE).
#' @param order Order for analysis: "reac" or "drug" (default is "reac").
#' @param threshold Threshold for analysis (default is 1).
#'
#' @return A data.table containing disproportionality analysis results.
#'
#' @importFrom questionr odds.ratio
#'
#' @export
disproportionality_analisis <- function(drug_selected, reac_selected, temp_d = Drug, temp_r = Reac, meddra_level = "pt", restriction = "none", sign_ciphers = 2, threshold_ROR = 3, threshold_IC = 1, event_names = "none", KeepLessThanThreshold = TRUE, order = "reac", threshold = 1) {
  ROR_df <- data.table()
  if (length(restriction) > 1) {
    temp_d <- temp_d[primaryid %in% restriction]
    temp_r <- temp_r[primaryid %in% restriction]
  }
  temp_r <- temp_r[, c(meddra_level, "primaryid"), with = FALSE]
  temp_d <- temp_d[, .(substance, primaryid)] %>% distinct()
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
        temp_drug_selected <- distinct(temp_d[primaryid %in% pids_r][, .(substance, primaryid)])[, .N, by = "substance"][substance %in% drug_selected][N >= threshold]$substance
      }
      for (d in temp_drug_selected) {
        pids_d <- unique(temp_d[substance %in% d]$primaryid)
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
      pids_d <- unique(temp_d[substance %in% d]$primaryid)
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
  ROR_df <- ROR_df %>% distinct()
  return(ROR_df)
}

#' Render Forest Plot
#'
#' This function generates a forest plot visualization of disproportions.
#'
#' @param df Data.table containing the data for rendering the forest plot.
#' @param TTO_ROR Type of data to use for rendering: "TTO", "ROR", "ROR_disp", or "IC".
#' @param levs_row Levels for the rows of the forest plot.
#' @param facet_v Variable for vertical facetting (default is "event").
#' @param facet_h Variable for horizontal facetting (default is NA).
#' @param row Variable for the rows of the forest plot (default is "drug").
#' @param nested Logical indicating if nested plotting is required (default is FALSE).
#' @param text_size_legend Size of text in the legend (default is 15).
#' @param transformation Transformation for the x-axis (default is "identity").
#' @param nested_colors Vector of colors for plot elements.
#' @param threshold Threshold value for analysis (default is 1).
#' @param dodge Position adjustment for dodging (default is 0.3).
#' @param show_legend Logical indicating whether to show the legend (default is FALSE).
#'
#' @return A ggplot object representing the forest plot visualization.
#'
#'
#' @export

render_forest <- function(df, TTO_ROR = "ROR", levs_row = unique(df$drug), facet_v = "event", facet_h = NA, row = "drug", nested = FALSE, text_size_legend = 15, transformation = "identity", nested_colors = NA, threshold = 1, dodge = .3, show_legend = FALSE) {
  if (TTO_ROR == "TTO") {
    df <- df[, median := TTO]
    xlab <- "Time to onset (dd)"
  }
  if (TTO_ROR == "ROR") {
    df <- df[, median := ROR]
    df <- df[, lower := ROR_lower]
    df <- df[, upper := ROR_upper]
    df <- df[, color := color_ROR]
    df <- df[
      , color_line := factor(color, levels = c("no signal", "light signal", "strong signal"), ordered = TRUE)
    ]
    levels(df$color_line) <- c("gray", "yellow", "red")
    xlab <- "Reporting Odds Ratio"
  }
  if (TTO_ROR == "IC") {
    df <- df[, median := IC]
    df <- df[, lower := IC_lower]
    df <- df[, upper := IC_upper]
    df <- df[, color := color_IC]
    df <- df[
      , color_line := factor(color, levels = c("no signal", "strong signal"), ordered = TRUE)
    ]
    levels(df$color_line) <- c("gray", "red")
    xlab <- "Information Component"
  }
  ggplot(data = df, aes(y = factor(get(row), levels = levs_row))) +
    {
      if (nested == FALSE) geom_linerange(aes(x = median, xmin = lower, xmax = upper, color = color_line), alpha = 0.7, size = 1, show.legend = show_legend, data = df)
    } +
    {
      if (nested != FALSE) geom_linerange(aes(x = median, xmin = lower, xmax = upper, color = nested, alpha = ifelse(lower > threshold, 1, .8)), size = 1, position = position_dodge(dodge), show.legend = show_legend, data = df)
    } +
    {
      if (nested == FALSE) geom_point(aes(x = median, color = color_line, size = (log10(cases))), alpha = 0.7, show.legend = show_legend, data = df)
    } +
    {
      if (nested != FALSE) geom_point(aes(x = median, color = nested, alpha = ifelse(lower > threshold, 1, .8), size = (log10(cases))), position = position_dodge(dodge), show.legend = show_legend, data = df)
    } +
    geom_vline(aes(xintercept = threshold), linetype = "dashed") +
    geom_vline(aes(xintercept = 0)) +
    xlab(xlab) +
    ylab("") +
    scale_x_continuous(trans = transformation) +
    {
      if (!is.na(facet_v)) facet_wrap(factor(get(facet_v)) ~ ., labeller = label_wrap_gen(width = 15), ncol = 4)
    } +
    {
      if (!is.na(facet_h)) facet_grid(rows = facet_h, labeller = label_wrap_gen(width = 25), scales = "free", space = "free", switch = "y")
    } +
    theme_bw() +
    theme(
      strip.placement = "outside", strip.text.y.left = element_text(angle = 0, size = 7), legend.position = "bottom",
      legend.justification = "left",
      legend.title = element_blank()
    ) +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    scale_size_area(guide = "none") +
    {
      if (nested == FALSE) scale_color_manual(values = levels(df$color_line), drop = FALSE)
    } +
    {
      if (nested == TRUE) scale_color_manual(values = nested_colors, drop = FALSE)
    } +
    scale_alpha_continuous(guide = "none") +
    labs(color = "Analysis")
}

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
#' @param ROR_minimum_cases Threshold for calculating Reporitng Odds Ratio (default is 3).
#' @param IC_threshold Threshold for calculating Information Component (default is 1).
#' @param ROR_threshold Threshold for analysis (default is 1).
#'
#' @return A data.table containing disproportionality analysis results.
#'
#' @importFrom questionr odds.ratio
#'
#' @export
disproportionality_analisis <- function(
    drug_selected, reac_selected,
    temp_d = Drug, temp_r = Reac,
    meddra_level = "pt",
    restriction = "none",
    ROR_minimum_cases = 3,
    ROR_threshold = 1,
    IC_threshold = 0) {
  if (length(restriction) > 1) {
    temp_d <- temp_d[primaryid %in% restriction] %>% droplevels()
    temp_r <- temp_r[primaryid %in% restriction] %>% droplevels()
  }
  if (meddra_level != "pt" & meddra_level != "custom") {
    if (!exists("MedDRA")) {
      stop("The MedDRA dictionary is not uploaded.
                                Without it, only analyses at the PT level are possible")
    }
    temp_r <- MedDRA[, c(meddra_level, "pt"), with = FALSE][temp_r, on = "pt"]
  }
  if (meddra_level == "custom") {
    df_custom <- data.table(
      custom = rep(names(reac_selected), lengths(reac_selected)),
      pt = unlist(reac_selected)
    )
    temp_r <- df_custom[temp_r, on = "pt"]
    reac_selected <- names(reac_selected)
  }
  temp_r <- temp_r[, c(meddra_level, "primaryid"), with = FALSE] %>% distinct()
  temp_d <- temp_d[, .(substance, primaryid)] %>% distinct()
  TOT <- length(unique(temp_d$primaryid))
  temp_d1 <- temp_d[substance %in% drug_selected][, .(primaryid_substance = list(primaryid)), by = "substance"]
  temp_r1 <- temp_r[get(meddra_level) %in% reac_selected][, .(primaryid_event = list(primaryid)), by = meddra_level]
  colnames(temp_r1) <- c("event", "primaryid_event")
  results <- setDT(expand.grid("substance" = unlist(drug_selected), "event" = unlist(reac_selected)))
  results <- results[temp_d1, on = "substance"]
  results <- results[temp_r1, on = "event"]
  results <- results[, D_E := as.numeric(map2(primaryid_substance, primaryid_event, \(x, y)length(intersect(x, y))))]
  results <- results[, D_nE := as.numeric(map2(primaryid_substance, primaryid_event, \(x, y)length(setdiff(x, y))))]
  results <- results[, D := D_E + D_nE]
  results <- results[, nD_E := as.numeric(map2(primaryid_event, primaryid_substance, \(x, y)length(setdiff(x, y))))]
  results <- results[, E := D_E + nD_E]
  results <- results[, nD_nE := TOT - (D_E + D_nE + nD_E)]
  ROR <- lapply(seq(1:nrow(results)), function(x) {
    tab <- as.matrix(data.table(
      E = c(results$nD_E[[x]], results$nD_E[[x]]),
      nE = c(results$D_nE[[x]], results$nD_nE[[x]])
    ))
    or <- questionr::odds.ratio(tab)
    ROR_median <- floor(or$OR * 100) / 100
    ROR_lower <- floor(or$`2.5 %` * 100) / 100
    ROR_upper <- floor(or$`97.5 %` * 100) / 100
    p_value_fisher <- or$p
    return(list(ROR_median, ROR_lower, ROR_upper, p_value_fisher))
  })
  results <- results[, ROR_median := as.numeric(map(ROR, \(x) x[[1]]))][
    , ROR_lower := as.numeric(map(ROR, \(x) x[[2]]))
  ][
    , ROR_upper := as.numeric(map(ROR, \(x) x[[3]]))
  ][
    , p_value_fisher := as.numeric(map(ROR, \(x) x[[4]]))
  ]
  results <- results[, Bonferroni := results$p_value_fisher * sum(results$D_E >= 3)]
  IC <- lapply(seq(1:nrow(results)), function(x) {
    IC_median <- log2((results$D_E[[x]] + .5) / (((results$D[[x]] * results$E[[x]]) / TOT) + .5))
    IC_lower <- floor((IC_median - 3.3 * (results$D_E[[x]] + .5)^(-1 / 2) - 2 * (results$D_E[[x]] + .5)^(-3 / 2)) * 100) / 100
    IC_upper <- floor((IC_median + 2.4 * (results$D_E[[x]] + .5)^(-1 / 2) - 0.5 * (results$D_E[[x]] + .5)^(-3 / 2)) * 100) / 100
    IC_median <- floor(IC_median * 100) / 100
    return(list(IC_median, IC_lower, IC_upper))
  })

  results <- results[, IC_median := as.numeric(map(IC, \(x) x[[1]]))][
    , IC_lower := as.numeric(map(IC, \(x) x[[2]]))
  ][
    , IC_upper := as.numeric(map(IC, \(x) x[[3]]))
  ]
  results <- results[, label_ROR := paste0(ROR_median, " (", ROR_lower, "-", ROR_upper, ") [", D_E, "]")]
  results <- results[, label_IC := paste0(IC_median, " (", IC_lower, "-", IC_upper, ") [", D_E, "]")]
  results <- results[, Bonferroni := p_value_fisher < 0.05 / nrow(results[D_E >= ROR_minimum_cases])]
  results$color_ROR <- as.character(NA)
  results <- results[, color_ROR := ifelse(D_E < ROR_minimum_cases, "not enough cases", ifelse(is.nan(ROR_lower), "all_associated",
    ifelse(ROR_lower <= ROR_threshold, "no signal",
      ifelse(Bonferroni == FALSE, "light signal",
        "strong signal"
      )
    )
  ))]
  results <- results[, color_IC := ifelse(is.nan(IC_lower), "all_associated",
    ifelse(IC_lower <= IC_threshold, "no signal",
      "strong signal"
    )
  )]
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

render_forest <- function(df, TTO_ROR = "ROR", levs_row = unique(df$substance), facet_v = "event", facet_h = NA, row = "substance", nested = FALSE, text_size_legend = 15, transformation = "identity", nested_colors = NA, threshold = 1, dodge = .3, show_legend = FALSE) {
  if (TTO_ROR == "TTO") {
    df <- df[, median := TTO]
    xlab <- "Time to onset (dd)"
  }
  if (TTO_ROR == "ROR") {
    df <- df[, median := ROR_median]
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
    df <- df[, median := IC_median]
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
      if (nested == FALSE) geom_point(aes(x = median, color = color_line, size = (log10(D_E))), alpha = 0.7, show.legend = show_legend, data = df)
    } +
    {
      if (nested != FALSE) geom_point(aes(x = median, color = nested, alpha = ifelse(lower > threshold, 1, .8), size = (log10(D_E))), position = position_dodge(dodge), show.legend = show_legend, data = df)
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

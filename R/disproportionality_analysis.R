#' Perform Disproportionality Analysis
#'
#' performs disproportionality analysis and returns the results.
#'
#' @param drug_selected A list of drugs for analysis. Can be a list of lists (to collapse terms together) if drug_level is set to custom.
#' @param reac_selected A list of adverse events for analysis. Can be a list of lists (to collapse terms together) if meddra_level is set to custom.
#' @param temp_d Data table containing drug data (default is Drug). If set to Drug[role_cod %in% c("PS","SS")] allows to investigate only suspects.
#' @param temp_r Data table containing reaction data (default is Reac).
#' @param meddra_level The desired MedDRA level for analysis (default is "pt"). If set to "custom" allows a list of lists for reac_selected (collapsing multiple terms).
#' @param drug_level The desired drug level for analysis (default is "substance"). If set to "custom" allows a list of lists for reac_selected (collapsing multiple terms).
#' @param restriction Primary IDs to consider for analysis (default is "none", which includes the entire population). If set to Demo[!RB_duplicates_only_susp]$primaryid, for example, allows to exclude duplicates according to one of the deduplication algorithms.
#' @param ROR_minimum_cases Threshold of minimum cases for calculating Reporitng Odds Ratio (default is 3).
#' @param IC_threshold Threshold for defining the significance of the lower limit of the Information Component (default is 0).
#' @param ROR_threshold Threshold for defining the significance of the lower limit of the Reporting Odds Ratio (default is 1).
#'
#' @return A data.table containing disproportionality analysis results.
#'
#' @importFrom questionr odds.ratio
#'
#' @export
disproportionality_analysis <- function(
    drug_selected, reac_selected,
    temp_d = Drug, temp_r = Reac,
    meddra_level = "pt",
    drug_level = "substance",
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
  temp_r <- temp_r[, c(meddra_level, "primaryid"), with = FALSE] %>% distinct()
  temp_d <- temp_d[, c(drug_level, "primaryid"), with = FALSE] %>% distinct()
  TOT <- length(unique(temp_d$primaryid))
  temp_d1 <- temp_d[get(drug_level) %in% drug_selected][, .(primaryid_substance = list(primaryid)), by = drug_level]
  temp_r1 <- temp_r[get(meddra_level) %in% reac_selected][, .(primaryid_event = list(primaryid)), by = meddra_level]
  colnames(temp_r1) <- c("event", "primaryid_event")
  colnames(temp_d1) <- c("substance", "primaryid_substance")
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
      E = c(results$D_E[[x]], results$nD_E[[x]]),
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
  results <- results[, ROR_color := ifelse(D_E < ROR_minimum_cases, "not enough cases", ifelse(is.nan(ROR_lower), "all_associated",
    ifelse(ROR_lower <= ROR_threshold, "no signal",
      ifelse(Bonferroni == FALSE, "light signal",
        "strong signal"
      )
    )
  ))]
  results <- results[, IC_color := ifelse(is.nan(IC_lower), "all_associated",
    ifelse(IC_lower <= IC_threshold, "no signal",
      "strong signal"
    )
  )]
  results <- results[, ROR_color := factor(ROR_color, levels = c("not enough cases", "no signal", "light signal", "strong signal"), ordered = TRUE)]
  results <- results[, IC_color := factor(IC_color, levels = c("no signal", "strong signal"), ordered = TRUE)]
}


#' Render Forest Plot
#'
#' This function generates a forest plot visualization of disproportions.
#'
#' @param df Data.table containing the data for rendering the forest plot.
#' @param index Type of data to use for rendering: "ROR" or "IC".
#' @param row Variable for the rows of the forest plot (default is "drug").
#' @param levs_row Levels for the rows of the forest plot.
#' @param facet_v Variable for vertical facetting (default is "event").
#' @param facet_h Variable for horizontal facetting (default is NA).
#' @param nested Variable indicating if nested plotting is required (default is FALSE). If nested plotting is required the name of the variable should replace FALSE.
#' @param text_size_legend Size of text in the legend (default is 15).
#' @param transformation Transformation for the x-axis (default is "identity").
#' @param nested_colors Vector of colors for plot elements.
#' @param custom_threshold Threshold value for analysis (default is 1).
#' @param dodge Position adjustment for dodging (default is 0.3).
#' @param show_legend Logical indicating whether to show the legend (default is FALSE).
#'
#' @return A ggplot object representing the forest plot visualization.
#'
#'
#' @export

render_forest <- function(df,
                          index = "IC",
                          row = "substance",
                          levs_row = NA,
                          nested = FALSE,
                          show_legend = TRUE,
                          transformation = "identity",
                          custom_threshold = NA,
                          text_size_legend = 15,
                          dodge = .3,
                          nested_colors = NA,
                          facet_v = NA,
                          facet_h = NA) {
  if (length(levs_row) == 1) {
    levs_row <- factor(unique(df[[row]])) %>% droplevels()
  }
  if (index == "ROR") {
    colors <- c("gray25", "gray", "yellow", "red")
    threshold <- 1
  }
  if (index == "IC") {
    colors <- c("gray", "red")
    threshold <- 0
  }
  if (!is.na(custom_threshold)) {
    threshold <- custom_threshold
  }
  df$median <- df[[paste0(index, "_median")]]
  df$lower <- df[[paste0(index, "_lower")]]
  df$upper <- df[[paste0(index, "_upper")]]
  df$color <- df[[paste0(index, "_color")]]
  if (nested != FALSE) {
    df$nested <- df[[nested]]
    colors <- nested_colors
    if (is.na(colors)) {
      colors <- c(
        "goldenrod", "steelblue", "salmon2",
        "green4", "brown", "violet", "blue4"
      )[1:length(unique(df[[nested]]))]
    }
  }

  ggplot(
    data = df, aes(
      x = median, xmin = lower, xmax = upper,
      y = factor(get(row), levels = levs_row)
    ),
    position = position_dodge(dodge), show.legend = show_legend,
    alpha = 0.7
  ) +
    {
      if (nested == FALSE) {
        geom_linerange(aes(color = color), size = 1)
      }
    } +
    {
      if (nested == FALSE) {
        geom_point(aes(color = color, size = (log10(D_E))))
      }
    } +
    {
      if (nested != FALSE) geom_linerange(aes(color = nested, alpha = ifelse(lower > threshold, 1, .8)), position = position_dodge(dodge), size = 1)
    } +
    {
      if (nested != FALSE) geom_point(aes(color = nested, alpha = ifelse(lower > threshold, 1, .8), size = (log10(D_E))), position = position_dodge(dodge))
    } +
    {
      if (!is.na(facet_v)) facet_wrap(factor(get(facet_v)) ~ ., labeller = label_wrap_gen(width = 15), ncol = 4)
    } +
    {
      if (!is.na(facet_h)) facet_grid(rows = facet_h, labeller = label_wrap_gen(width = 25), scales = "free", space = "free", switch = "y")
    } +
    geom_vline(aes(xintercept = threshold), linetype = "dashed") +
    xlab(index) +
    ylab("") +
    scale_x_continuous(trans = transformation) +
    theme_bw() +
    scale_alpha_continuous(range = c(0.4, 1), guide = "none") +
    guides(shape = guide_legend(override.aes = list(size = 5))) +
    scale_size_area(guide = "none") +
    {
      if (nested == FALSE) labs(color = "Signal")
    } +
    {
      if (nested != FALSE) labs(color = "Analysis")
    } +
    scale_color_manual(values = colors, drop = FALSE) +
    theme(
      strip.placement = "outside", strip.text.y.left = element_text(angle = 0, size = 7), legend.position = "bottom",
      legend.justification = "left",
      legend.title = element_blank()
    ) +
    guides(shape = guide_legend(override.aes = list(size = 5)))
}

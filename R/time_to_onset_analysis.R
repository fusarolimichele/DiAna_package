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
#' @param test The two-sample goodness of fit test to apply for TTO analysis. Choices are AD (Anderson-Darling test - default) and KS (Kolmogorov-Smirnov test).
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
#' @references
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
    max_TTO = 365,
    test = "AD") {
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

  #### Perform test
  if (test == "AD") {
    results <- results[lengths(D_E) > 0]
    results <- results[lengths(nD_E) > 0]
    results <- results[, ad_event := map2(D_E, nD_E, \(x, y) ad_test(unlist(x), unlist(y)))]
    results <- results[lengths(D_nE) > 0]
    results <- results[, ad_drug := map2(D_E, nD_E, \(x, y) ad_test(unlist(x), unlist(y)))]
    results <- results[, index := .I]
    results <- results[, D_event := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ad_event[[x]][[1]], NA))]
    results <- results[, p_event := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ad_event[[x]][[2]], NA))]
    results <- results[, D_drug := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ad_drug[[x]][[1]], NA))]
    results <- results[, p_drug := map2(index, D_E, \(x, y) ifelse(length(unlist(y)) >= minimum_cases, ad_drug[[x]][[2]], NA))]
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

  if (test == "KS") {
    results <- results[lengths(D_E) > 0]
    results <- results[lengths(nD_E) > 0]
    results <- results[, ks_event := map2(D_E, nD_E, \(x, y) ks.test(unlist(x), unlist(y),
      alternative = "two.sided", exact = FALSE
    ))]
    results <- results[lengths(D_nE) > 0]
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
}

#' Plot Kolmogorov-Smirnov (KS) plot
#'
#' This function generates a KS plot for comparing two distributions using the
#' Kolmogorov-Smirnov statistic.
#'
#' @param results_tto_analysis The results of the time-to-event analysis.
#' @param RG Specifies whether the drug-event combination of interest should be compared with other reports of the "drug" or of the "event".
#'
#' @return A ggplot object representing the KS plot.
#'
#' @details
#' The function takes the results of a time-to-event analysis and compares
#' two distributions based on the specified type of data (drug or event).
#' It uses the ggplot2 package to create a KS plot, highlighting the points
#' of greatest distance between the cumulative distribution functions (CDFs)
#' of the two groups.
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' plot_KS(results_tto_analysis, RG = "drug")
#' }
#'
#' @export
plot_KS <- function(results_tto_analysis, RG = "drug") {
  # simulate two distributions - your data goes here!
  sample1 <- unlist(results_tto_analysis$D_E)
  if (RG == "drug") {
    sample2 <- unlist(results_tto_analysis$D_nE)
  } else if (RG == "event") {
    sample2 <- unlist(results_tto_analysis$nD_E)
  }
  group <- c(rep("Cases", length(sample1)), rep("RG", length(sample2)))
  dat <- data.frame(KSD = c(sample1, sample2), group = group)
  # create ECDF of data
  cdf1 <- ecdf(sample1)
  cdf2 <- ecdf(sample2)
  # find min and max statistics to draw line between points of greatest distance
  minMax <- seq(min(sample1, sample2), max(sample1, sample2), length.out = length(sample1))
  x0 <- minMax[which(abs(cdf1(minMax) - cdf2(minMax)) == max(abs(cdf1(minMax) - cdf2(minMax))))]
  y0 <- cdf1(x0)
  y1 <- cdf2(x0)

  ks_plot <- ggplot(dat, aes(x = KSD, group = group, color = group)) +
    stat_ecdf(linewidth = 1) +
    theme_bw(base_size = 28) +
    theme(legend.position = "top") +
    xlab("days") +
    ylab("cumulative distribution") +
    # geom_line(size=1) +
    geom_segment(aes(x = x0[1], y = y0[1], xend = x0[1], yend = y1[1]),
      linetype = "dashed", color = "red"
    ) +
    geom_point(aes(x = x0[1], y = y0[1]), color = "red", size = 8) +
    geom_point(aes(x = x0[1], y = y1[1]), color = "red", size = 8) +
    theme(legend.title = element_blank())
  ks_plot
}


#' TTO Render Forest Plot
#'
#' This function generates a forest plot visualization of time to onset analysis
#'
#' @param df Data.table containing the data for rendering the forest plot.
#' @param row Variable for the rows of the forest plot (default is "substance").
#' @param levs_row Levels for the rows of the forest plot.
#' @param facet_v Variable for vertical facetting (default is "NA", it could be setted to e.g., "event").
#' @param facet_h Variable for horizontal facetting (default is NA).
#' @param nested Variable indicating if nested plotting is required (default is FALSE). If nested plotting is required the name of the variable should replace FALSE.
#' @param text_size_legend Size of text in the legend (default is 15).
#' @param transformation Transformation for the x-axis (default is "identity").
#' @param nested_colors Vector of colors for plot elements.
#' @param dodge Position adjustment for dodging (default is 0.3).
#' @param show_legend Logical indicating whether to show the legend (default is FALSE).
#'
#' @return A ggplot object representing the forest plot visualization.
#'
#'
#' @export

render_tto <- function(df,
                       row = "substance",
                       levs_row = NA,
                       nested = FALSE,
                       show_legend = TRUE,
                       transformation = "log10",
                       text_size_legend = 15,
                       dodge = .3,
                       nested_colors = NA,
                       facet_v = NA,
                       facet_h = NA) {
  if (length(levs_row) == 1) {
    levs_row <- factor(unique(df[[row]])) %>% droplevels()
  }
  colors <- c("gray", "orange", "red")

  df$median <- as.numeric(df$Q2)
  df$lower <- as.numeric(df$min)
  df$upper <- as.numeric(df$max)
  df$color <- ifelse(df$p_event <= 0.05 & df$p_drug <= 0.05, "red", ifelse(df$p_event <= 0.05 | df$p_drug <= 0.05, "orange", "gray"))

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
        geom_linerange(aes(col = color), size = 1)
      }
    } +
    {
      if (nested == FALSE) {
        geom_point(aes(col = color))
      }
    } +
    {
      if (nested != FALSE) geom_linerange(aes(color = nested, position = position_dodge(dodge)), size = 1)
    } +
    {
      if (nested != FALSE) geom_point(aes(color = nested, position = position_dodge(dodge)))
    } +
    {
      if (!is.na(facet_v)) facet_wrap(factor(get(facet_v)) ~ ., labeller = label_wrap_gen(width = 15), ncol = 4)
    } +
    {
      if (!is.na(facet_h)) facet_grid(rows = facet_h, labeller = label_wrap_gen(width = 25), scales = "free", space = "free", switch = "y")
    } +
    {
      if (!is.na(facet_h) & !is.na(facet_v)) facet_grid(factor(get(facet_h)) ~ factor(get(facet_v)), labeller = label_wrap_gen(width = 15), scales = "free", space = "free", switch = "y")
    } +
    xlab("TTO (days)") +
    ylab("") +
    scale_x_continuous(trans = transformation) +
    scale_color_manual(values = c(red = "red", orange = "orange", gray = "gray")) +
    theme_bw() +
    scale_size_area(guide = "none") +
    guides(shape = guide_legend(override.aes = list(size = 5)), col = "none")
}

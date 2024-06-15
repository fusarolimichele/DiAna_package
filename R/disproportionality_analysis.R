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

#' Disproportionality Analysis for Drug-Event Combinations
#'
#' This function performs a disproportionality analysis for drug-event combinations in the FAERS dataset, calculating various metrics such as the Reporting Odds Ratio (ROR), Proportional Reporting Ratio (PRR), Relative Reporting Ratio (RRR), and Information Component (IC).
#'
#' @param drug_count An integer representing the number of reports for the drug of interest. Default is the length of \code{pids_drug}.
#' @param event_count An integer representing the number of reports for the event of interest. Default is the length of \code{pids_event}.
#' @param drug_event_count An integer representing the number of reports for the drug-event combination. Default is the length of the intersection of \code{pids_drug} and \code{pids_event}.
#' @param tot An integer representing the total number of reports in the dataset. Default is the number of rows in the \code{Demo} table.
#' @return This function prints a contingency table and several disproportionality metrics:
#' \itemize{
#'   \item \code{ROR}: Reporting Odds Ratio with confidence intervals.
#'   \item \code{PRR}: Proportional Reporting Ratio with confidence intervals.
#'   \item \code{RRR}: Relative Reporting Ratio with confidence intervals.
#'   \item \code{IC}: Information Component with confidence intervals.
#'   \item \code{IC_gamma}: Gamma distribution-based Information Component with confidence intervals.
#' }
#' @details
#' The function constructs a contingency table for the drug-event combination and computes the following metrics:
#' \describe{
#'   \item{\code{ROR}}{Reporting Odds Ratio: Based on odds ratio}
#'   \item{\code{PRR}}{Proportional Reporting Ratio: The expected probability of the event is calculated on the population not having the drug of interest.}
#'   \item{\code{RRR}}{Relative Reporting Ratio: The expected probability of the event is calculated on the entire population.}
#'   \item{\code{IC}}{Information Component: A measure based on Bayesian confidence propagation neural network models. It is the log2 of the shrinked RRR.}
#'   \item{\code{IC_gamma}}{Gamma distribution-based Information Component: An alternative IC calculation using the gamma distribution.}
#' }
#' @importFrom questionr odds.ratio
#' @importFrom data.table data.table
#' @export
#' @examples
#' # Perform disproportionality analysis with custom parameters
#' disproportionality_comparison(drug_count = 100, event_count = 50, drug_event_count = 10, tot = 10000)
disproportionality_comparison <- function(drug_count = length(pids_drug), event_count = length(pids_event),
                                          drug_event_count = length(intersect(pids_drug, pids_event)), tot = nrow(Demo)) {
  tab <- as.matrix(data.table(
    E = c(drug_event_count, event_count - drug_event_count),
    nE = c(drug_count - drug_event_count, tot - event_count - (drug_count - drug_event_count))
  ))
  rownames(tab) <- c("D", "nD")
  print(tab)
  cat("\n")
  cat("\n")
  or <- questionr::odds.ratio(tab)
  ROR_median <- floor(or$OR * 100) / 100
  ROR_lower <- floor(or$`2.5 %` * 100) / 100
  ROR_upper <- floor(or$`97.5 %` * 100) / 100
  IC_median <- log2((drug_event_count + .5) / (((drug_count * event_count) / tot) + .5))
  IC_lower <- floor((IC_median - 3.3 * (drug_event_count + .5)^(-1 / 2) - 2 * (drug_event_count + .5)^(-3 / 2)) * 100) / 100
  IC_upper <- floor((IC_median + 2.4 * (drug_event_count + .5)^(-1 / 2) - 0.5 * (drug_event_count + .5)^(-3 / 2)) * 100) / 100
  gamma_lower <- log2(stats::qgamma(
    p = .025,
    shape = drug_event_count + 0.5,
    rate = ((drug_count * event_count) / tot) + 0.5
  ))
  gamma_median <- log2(stats::qgamma(
    p = .05,
    shape = drug_event_count + 0.5,
    rate = ((drug_count * event_count) / tot) + 0.5
  ))
  gamma_upper <- log2(stats::qgamma(
    p = .975,
    shape = drug_event_count + 0.5,
    rate = ((drug_count * event_count) / tot) + 0.5
  ))
  IC_median <- floor(IC_median * 100) / 100
  RRR_median <- drug_event_count / ((drug_count * event_count) / tot)
  RRR_lower <- (drug_event_count) / (drug_count * event_count / tot) * exp(stats::qnorm(.025) * sqrt(1 / drug_event_count - 1 / drug_count + 1 / event_count - 1 / tot))
  RRR_upper <- (drug_event_count) / (drug_count * event_count / tot) * exp(stats::qnorm(.975) * sqrt(1 / drug_event_count - 1 / drug_count + 1 / event_count - 1 / tot))
  PRR_median <- (drug_event_count) / (tot * (drug_count / tot) * ((event_count - drug_event_count) / (tot - drug_count)))
  PRR_lower <- (drug_event_count) / (drug_count * (event_count - drug_event_count) / (tot - drug_count)) * exp(stats::qnorm(.025) * sqrt(1 / drug_event_count - 1 / drug_count + 1 / (event_count - drug_event_count) - 1 / (tot - drug_count)))
  PRR_upper <- (drug_event_count) / (drug_count * (event_count - drug_event_count) / (tot - drug_count)) * exp(stats::qnorm(.975) * sqrt(1 / drug_event_count - 1 / drug_count + 1 / (event_count - drug_event_count) - 1 / (tot - drug_count)))

  cat(paste0("ROR = ", ROR_median, " (", ROR_lower, "-", ROR_upper, ")\n"))
  cat(paste0("PRR = ", round(PRR_median, 2), " (", round(PRR_lower, 2), "-", round(PRR_upper, 2), ")\n"))
  cat(paste0("RRR = ", round(RRR_median, 2), " (", round(RRR_lower, 2), "-", round(RRR_upper, 2), ")\n"))
  cat(paste0("IC = ", IC_median, " (", IC_lower, "-", IC_upper, ")\n"))
  cat(paste0("IC_gamma = ", round(gamma_median, 2), " (", round(gamma_lower, 2), "-", round(gamma_upper, 2), ")"))
}


#' Disproportionality Time Trend for a Drug-Event Combination
#'
#' This function calculates the disproportionality time trend for a given drug-event combination.
#'
#' @param drug_selected Drug selected
#' @param reac_selected Event selected
#' @param temp_d Data frame containing drug data. Defaults to `Drug`.
#' @param temp_r Data frame containing reaction data. Defaults to `Reac`.
#' @param temp_demo Data frame containing demographic data. Defaults to `Demo`.
#' @param meddra_level Character string specifying the MedDRA level. Options are "pt" (preferred term) or "custom". Defaults to "pt".
#' @param drug_level Character string specifying the drug level. Options are "substance" or "custom". Defaults to "substance".
#' @param restriction Character vector of primary IDs to restrict the analysis. Defaults to "none".
#' @param time_granularity Character string specifying the time granularity. Options are "year", "quarter", or "month". Defaults to "year".
#' @param cumulative Logical indicating whether to calculate cumulative values. Defaults to `TRUE`.
#'
#' @return A data frame containing the disproportionality results over time, including:
#' \item{period}{Time period}
#' \item{TOT}{Total number of reports}
#' \item{D_E}{Number of reports with both drug and event}
#' \item{D_nE}{Number of reports with the drug but not the event}
#' \item{D}{Total number of reports with the drug}
#' \item{nD_E}{Number of reports with the event but not the drug}
#' \item{E}{Total number of reports with the event}
#' \item{nD_nE}{Number of reports with neither the drug nor the event}
#' \item{ROR_median}{Reporting odds ratio (ROR) median}
#' \item{ROR_lower}{ROR lower bound (2.5%)}
#' \item{ROR_upper}{ROR upper bound (97.5%)}
#' \item{p_value_fisher}{Fisher's exact test p-value}
#' \item{Bonferroni}{Bonferroni-corrected p-value}
#' \item{IC_median}{Information component (IC) median}
#' \item{IC_lower}{IC lower bound}
#' \item{IC_upper}{IC upper bound}
#' \item{label_ROR}{Formatted ROR label}
#' \item{label_IC}{Formatted IC label}
#'
#' @details
#' The function processes the provided data to calculate the reporting odds ratio (ROR) and the information component (IC) for the specified drug-event combination over time.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' drug_selected <- "aspirin"
#' reac_selected <- "headache"
#' result <- disproportionality_trend(drug_selected, reac_selected)
#' }
#'
#' @export
disproportionality_trend <- function(
    drug_selected, reac_selected,
    temp_d = Drug, temp_r = Reac,
    temp_demo = Demo,
    meddra_level = "pt",
    drug_level = "substance",
    restriction = "none",
    time_granularity = "year",
    cumulative = TRUE) {
  if (length(restriction) > 1) {
    temp_d <- temp_d[primaryid %in% restriction] %>% droplevels()
    temp_r <- temp_r[primaryid %in% restriction] %>% droplevels()
    temp_demo <- temp_demo[primaryid %in% restriction] %>% droplevels()
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
  if (time_granularity == "year") {
    temp_demo <- temp_demo[, period := as.numeric(substr(
      ifelse(is.na(init_fda_dt),
        fda_dt, init_fda_dt
      ),
      1, 4
    ))][, period := ifelse(period < 2004, 2004, period)]
  }
  # ...quarter, month
  temp_demo <- temp_demo[, .(primaryid, period)][, .(pids = list(primaryid)), by = "period"]
  temp_r <- temp_r[, c(meddra_level, "primaryid"), with = FALSE] %>% distinct()
  temp_d <- temp_d[, c(drug_level, "primaryid"), with = FALSE] %>% distinct()
  temp_demo <- temp_demo[, TOT := unlist(map(pids, \(x) length(x)))]
  pids_d <- unique(temp_d[get(drug_level) %in% drug_selected]$primaryid)
  pids_r <- unique(temp_r[get(meddra_level) %in% reac_selected]$primaryid)
  results <- temp_demo
  results <- results[, pids_drug := map(pids, \(x) intersect(pids_d, x))]
  results <- results[, pids_reac := map(pids, \(x) intersect(pids_r, x))]
  results <- results[, D_E := as.numeric(map2(pids_drug, pids_reac, \(x, y)length(intersect(x, y))))]
  results <- results[, D_nE := as.numeric(map2(pids_drug, pids_reac, \(x, y)length(setdiff(x, y))))]
  results <- results[, D := D_E + D_nE]
  results <- results[, nD_E := as.numeric(map2(pids_reac, pids_drug, \(x, y)length(setdiff(x, y))))]
  results <- results[, E := D_E + nD_E]
  results <- results[, nD_nE := TOT - (D_E + D_nE + nD_E)]
  if (cumulative == TRUE) {
    results <- results[, cum_D_E := Reduce(function(x, y) sum(x[[1]], y), D_E, accumulate = TRUE)]
    results <- results[, cum_D_nE := Reduce(function(x, y) sum(x[[1]], y), D_nE, accumulate = TRUE)]
    results <- results[, cum_D := Reduce(function(x, y) sum(x[[1]], y), D, accumulate = TRUE)]
    results <- results[, cum_nD_E := Reduce(function(x, y) sum(x[[1]], y), nD_E, accumulate = TRUE)]
    results <- results[, cum_E := Reduce(function(x, y) sum(x[[1]], y), E, accumulate = TRUE)]
    results <- results[, cum_nD_nE := Reduce(function(x, y) sum(x[[1]], y), nD_nE, accumulate = TRUE)]
    results <- results[, cum_TOT := Reduce(function(x, y) sum(x[[1]], y), TOT, accumulate = TRUE)]
    results <- results[, .(period, TOT = cum_TOT, D_E = cum_D_E, D_nE = cum_D_nE, D = cum_D, nD_E = cum_nD_E, E = cum_E, nD_nE = cum_nD_nE)]
  }
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
    IC_median <- log2((results$D_E[[x]] + .5) / (((results$D[[x]] * results$E[[x]]) / results$TOT[[x]]) + .5))
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
  return(results)
}

#' Plot Disproportionality Trend
#'
#' This function plots the disproportionality trend over time for a given metric.
#'
#' @param disproportionality_trend_results Data frame containing the results from the `disproportionality_trend` function.
#' @param metric Character string specifying the metric to plot. Options are "IC" (information component) or "ROR" (reporting odds ratio). Defaults to "IC".
#'
#' @return A ggplot object representing the disproportionality trend plot for the specified metric.
#'
#' @details
#' The function creates a plot to visualize the disproportionality trend of a drug-event combination over time. Depending on the selected metric, it plots either the information component (IC) or the reporting odds ratio (ROR) with corresponding confidence intervals.
#'
#' @examples
#' \dontrun{
#' # Example usage
#' trend_results <- disproportionality_trend(drug_selected = "aspirin", reac_selected = "headache")
#' plot_IC <- plot_disproportionality_trend(trend_results, metric = "IC")
#' plot_ROR <- plot_disproportionality_trend(trend_results, metric = "ROR")
#' }
#'
#' @export
plot_disproportionality_trend <- function(disproportionality_trend_results, metric = "IC") {
  if (metric == "IC") {
    plot <- ggplot(disproportionality_trend_results) +
      geom_pointrange(aes(x = period, y = IC_median, ymin = IC_lower, ymax = IC_upper, color = ifelse(IC_lower > 0, "signal", "no-signal"), size = D_E), fatten = 1, show.legend = FALSE) +
      geom_line(aes(x = period, y = IC_median), linetype = "dashed", color = "blue") +
      theme_bw() +
      xlab("") +
      ylab("IC") +
      scale_color_manual(values = c("no-signal" = "gray", "signal" = "red")) +
      theme(legend.title = element_blank())
  } else if (metric == "ROR") {
    plot <- ggplot(disproportionality_trend_results) +
      geom_pointrange(aes(x = period, y = ROR_median, ymin = ROR_lower, ymax = ROR_upper, color = ifelse(ROR_lower > 1, "signal", "no-signal"), size = D_E), fatten = 1, show.legend = FALSE) +
      geom_line(aes(x = period, y = ROR_median), linetype = "dashed", color = "blue") +
      theme_bw() +
      xlab("") +
      ylab("ROR") +
      scale_color_manual(values = c("no-signal" = "gray", "signal" = "red")) +
      theme(legend.title = element_blank())
  } else {
    (plot <- "Metrics not available")
  }
  return(plot)
}

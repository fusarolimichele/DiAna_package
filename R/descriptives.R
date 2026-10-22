#' Generate Descriptive Statistics for a Sample
#'
#' This function generates descriptive statistics for a sample of reports
#' (cases), optionally compared with a reference group (non-cases), and can
#' save the results to an Excel file.
#'
#' @param pids_cases A vector of primary IDs for cases.
#' @param RG A vector of primary IDs: reference group. Default is NULL.
#' @param drug A vector of drug names. Default is NULL.
#' @param file_name The name of the Excel file to save the results. Default is "Descriptives.xlsx". It only works if save_in_excel is TRUE.
#' @param vars A character vector of variable names to include in the analysis.
#' @param list_pids A list of vectors with primary IDs for custom groups whose distribution should be described. Default is an empty list.
#' @param method The method for Chi-square test analysis, either "independence_test" or "goodness_of_fit". Default is "independence_test". It applies only for comparisons between cases and non-cases.
#' @param save_in_excel Whether to also save the results in an Excel file, `file_name`. Defaults to `TRUE` only if `file_name` is supplied.
#' @param outcome How to describe the seriousness outcomes, when `"Outcome"`
#'   is in `vars`:
#'   \itemize{
#'     \item `"each"` (default): one row per outcome (Death, Life threatening,
#'       Disability, Required intervention, Hospitalization, Congenital
#'       anomaly, Other serious). A report with several outcomes counts in
#'       each of them, so the percentages do not add up to 100%.
#'     \item `"most_severe"`: one row per report, with its most severe
#'       outcome, in the order listed above.
#'   }
#'   See the section "Outcomes" for the denominator.
#' @param temp_demo Demo dataset. Defaults to Demo. Can be set to sample_Demo for testing
#' @param temp_drug Drug dataset. Can be set to sample_Drug for testing
#' @param temp_reac Reac dataset. Can be set to sample_Reac for testing
#' @param temp_indi Indi dataset. Can be set to sample_Indi for testing
#' @param temp_outc Outc dataset. Can be set to sample_Outc for testing
#' @param temp_ther Ther dataset. Can be set to sample_Ther for testing
#'
#' @section Outcomes:
#' A FAERS report records seriousness outcomes only when the reporter
#' provides them. A report without any recorded outcome is **not** known to be
#' non-serious: the information is simply missing, and nothing can be said
#' about the seriousness of that report. For this reason:
#' \itemize{
#'   \item the row "Seriousness recorded" gives the number and percentage of
#'     reports, among all reports, that record at least one outcome;
#'   \item the percentages of the outcome rows use as denominator only the
#'     reports with at least one recorded outcome. Reports without any
#'     recorded outcome are excluded from that denominator, not counted as
#'     non-serious.
#' }
#'
#' @return The descriptive statistics as a table (a tibble), with counts and
#'   percentages for cases and, if `RG` is given, for non-cases with p-values.
#'   If `save_in_excel = TRUE`, the table is also saved to `file_name`.
#' @importFrom dplyr distinct left_join
#' @importFrom writexl write_xlsx
#' @importFrom tibble as_tibble
#' @importFrom gtsummary add_p add_q all_categorical all_continuous all_continuous2 bold_labels style_pvalue tbl_summary
#' @importFrom here here
#' @importFrom tidyr separate
#' @importFrom readr read_delim
#' @examples
#' pids_cases <- unique(sample_Demo[sex == "M"]$primaryid)
#' RG <- unique(sample_Demo[sex == "F"]$primaryid)
#'
#' # Generate descriptive statistics for cases
#' descriptive(
#'   pids_cases = pids_cases,
#'   temp_demo = sample_Demo, temp_drug = sample_Drug,
#'   temp_reac = sample_Reac, temp_indi = sample_Indi,
#'   temp_outc = sample_Outc, temp_ther = sample_Ther
#' )
#'
#' # Generate descriptive statistics for cases and non-cases,
#' # describing only the most severe outcome of each report
#' descriptive(
#'   pids_cases = pids_cases, RG = RG, outcome = "most_severe",
#'   temp_demo = sample_Demo, temp_drug = sample_Drug,
#'   temp_reac = sample_Reac, temp_indi = sample_Indi,
#'   temp_outc = sample_Outc, temp_ther = sample_Ther
#' )
#' @export

descriptive <- function(pids_cases, RG = NULL, drug = NULL,
                        save_in_excel = !missing(file_name), file_name = "Descriptives.xlsx",
                        vars = c(
                          "sex", "Submission", "Reporter",
                          "age_range", "Outcome", "country",
                          "continent", "age_in_years",
                          "wt_in_kgs", "Reactions",
                          "Indications", "Substances", "num_Substances",
                          "year", "role_cod", "time_to_onset"
                        ),
                        list_pids = list(), method = "independence_test",
                        outcome = c("each", "most_severe"),
                        temp_demo = Demo, temp_drug = Drug, temp_reac = Reac,
                        temp_indi = Indi, temp_outc = Outc, temp_ther = Ther) {
  outcome <- match.arg(outcome)
  check_workspace_defaults(c("temp_demo", "temp_drug", "temp_reac", "temp_indi", "temp_outc"))
  if ("time_to_onset" %in% vars && !is.null(drug)) check_workspace_defaults("temp_ther")
  # import data (subsetting creates copies, so the tables passed in are not modified)
  pids_tot <- base::union(pids_cases, RG)
  temp_demo <- temp_demo[primaryid %in% pids_tot]
  temp_outc <- temp_outc[primaryid %in% pids_tot]
  temp_reac <- temp_reac[primaryid %in% pids_tot]
  temp_indi <- temp_indi[primaryid %in% pids_tot]
  temp_drug <- temp_drug[primaryid %in% pids_tot]

  temp <- temp_demo
  temp[, sex := ifelse(sex == "F", "Female", ifelse(sex == "M", "Male", NA))]
  if ("Submission" %in% vars) {
    temp[, Submission := ifelse(rept_cod %in% c("30DAY", "5DAY", "EXP"), "Expedited",
      ifelse(rept_cod == "PER", "Periodic",
        "Direct"
      )
    )]
  }
  temp[, Reporter := ifelse(occp_cod == "CN", "Consumer",
    ifelse(occp_cod == "MD", "Physician",
      ifelse(occp_cod == "HP", "Healthcare practitioner",
        ifelse(occp_cod == "PH", "Pharmacist",
          ifelse(occp_cod == "LW", "Lawyer",
            ifelse(occp_cod == "OT", "Other",
              ifelse(occp_cod == "NULL", NA,
                as.character(occp_cod)
              )
            )
          )
        )
      )
    )
  )]

  temp$Reporter <- as.factor(temp$Reporter)
  temp[, age_in_years := age_in_days / 365]
  temp[, age_range := cut(age_in_days, c(0, 28, 730, 4380, 6570, 10950, 18250, 23725, 27375, 31025, 36500, 73000),
    include.lowest = TRUE, right = FALSE,
    labels = c(
      "Neonate (<28d)", "Infant (28d-1y)", "Child (2y-11y)", "Teenager (12y-17y)", "Adult (18y-29y)", "Adult (30y-49y)",
      "Adult (50y-64y)", "Elderly (65y-74y)", "Elderly (75y-84y)", "Elderly (85y-99y)", "Elderly (>99y)"
    )
  )]

  # outcomes: reports without any recorded outcome are unknown, not non-serious
  outcome_vars <- character(0)
  if ("Outcome" %in% vars) {
    outcome_temp <- describe_outcomes(temp_outc, outcome)
    outcome_vars <- setdiff(names(outcome_temp), "primaryid")
    temp <- outcome_temp[temp, on = "primaryid"]
    temp[, Seriousness_recorded := primaryid %in% outcome_temp$primaryid]
    position <- match("Outcome", vars)
    vars <- append(vars[-position], c("Seriousness_recorded", outcome_vars), after = position - 1)
  }

  temp[, country := ifelse(is.na(as.character(occr_country)), as.character(reporter_country), as.character(occr_country))]
  if ("continent" %in% vars) {
    temp <- dplyr::distinct(country_dictionary[, .(country, continent)][!is.na(country)])[temp, on = "country"]
    temp$continent <- factor(temp$continent, levels = c("North America", "Europe", "Asia", "South America", "Oceania", "Africa"), ordered = TRUE)
  }
  temp$country <- as.factor(temp$country)
  temp <- temp_reac[, .N, by = "primaryid"][, .(primaryid, Reactions = N)][temp, on = "primaryid"]
  temp <- temp_drug[, .N, by = "primaryid"][, .(primaryid, Substances = N)][temp, on = "primaryid"]
  if ("num_Substances" %in% vars) {
    temp[, num_Substances := ifelse(Substances == 1, "1",
      ifelse(Substances == 2, "2",
        ifelse(Substances > 2 & Substances <= 5, "3-5", ">5")
      )
    )]
    temp$num_Substances <- factor(temp$num_Substances, levels = c("1", "2", "3-5", ">5"))
  }
  temp <- temp_indi[, .N, by = "primaryid"][, .(primaryid, Indications = N)][temp, on = "primaryid"]
  if ("year" %in% vars) {
    temp[, year := as.factor(ifelse(!is.na(event_dt),
      as.numeric(substr(event_dt, 1, 4)), ifelse(!is.na(init_fda_dt),
        as.numeric(substr(init_fda_dt, 1, 4)), as.numeric(substr(fda_dt, 1, 4))
      )
    ))]
  }
  # add the max role_cod and the time to onset for the drug
  if (!is.null(drug)) {
    if ("time_to_onset" %in% vars) {
      temp_ther <- temp_ther[primaryid %in% pids_tot]
      temp_tto <- temp_drug[temp_ther, on = c("primaryid", "drug_seq")][substance %in% drug]
      temp_tto <- temp_tto[!is.na(time_to_onset) & time_to_onset >= 0]
      suppressWarnings(temp_tto <- temp_tto[, .(time_to_onset = max(time_to_onset)), by = "primaryid"])
      temp <- temp_tto[temp, on = "primaryid"]
      temp$time_to_onset <- as.numeric(temp$time_to_onset)
    }
    temp_role <- temp_drug[substance %in% drug][
      , role_cod := factor(role_cod, levels = c("C", "I", "SS", "PS"), ordered = TRUE)
    ][
      , .(role_cod = max(role_cod)),
      by = "primaryid"
    ]
    suppressMessages(temp <- dplyr::left_join(temp, temp_role, by = "primaryid"))
  } else {
    vars <- setdiff(vars, c("role_cod", "time_to_onset"))
    warning("Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated")
  }
  labels <- if ("Seriousness_recorded" %in% vars) list(Seriousness_recorded = "Seriousness recorded") else NULL
  # the outcome rows have no "Unknown" row: the count of reports without
  # outcomes is given by "Seriousness recorded"
  drop_outcome_unknown <- function(x) x[!(x$variable %in% outcome_vars & x$row_type == "missing"), ]

  # descriptive only cases
  if (is.null(RG)) {
    # select the vars
    temp <- temp[, ..vars]
    t <- temp %>%
      gtsummary::tbl_summary(
        statistic = list(
          gtsummary::all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}]",
          gtsummary::all_categorical() ~ "{n};{p}"
        ), digits = colnames(temp) ~ c(0, 2),
        label = labels
      ) %>%
      gtsummary::modify_table_body(drop_outcome_unknown)
    # format the table
    gt_table <- t %>% tibble::as_tibble()
    tempN_cases <- as.numeric(gsub("\\*\\*", "", gsub(".*N = ", "", colnames(gt_table)[[2]])))
    suppressWarnings(gt_table <- gt_table %>% tidyr::separate(get(colnames(gt_table)[[2]]),
      sep = ";",
      into = c("N_cases", "%_cases")
    ))
    gt_table <- rbind(c("N", tempN_cases, ""), gt_table)
    # save it to the excel
    if (save_in_excel) {
      writexl::write_xlsx(gt_table, file_name)
    }
  } else {
    # descriptives cases and non-cases
    vars <- c(vars, "Group", names(list_pids))
    suppressWarnings(temp[, Group := ifelse(primaryid %in% pids_cases, "Cases", "Non-Cases")])
    if (method == "goodness_of_fit") {
      temp <- rbindlist(list(temp, temp[Group == "Cases"][, Group := "Non-Cases"]))
    }
    if (!is.null(names(list_pids))) {
      for (n in 1:length(list_pids)) {
        temp[[names(list_pids)[[n]]]] <- temp$primaryid %in% list_pids[[n]]
      }
    }
    temp <- temp[, ..vars]
    # perform the descriptive analysis
    suppressMessages(t <- temp %>%
      gtsummary::tbl_summary(
        by = Group, statistic = list(
          gtsummary::all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}] {p_nonmiss}",
          gtsummary::all_continuous2() ~ "{median} ({p25}-{p75}) [{min}-{max}] {p_nonmiss}%",
          gtsummary::all_categorical() ~ "{n};{p}"
        ),
        digits = everything() ~ c(0, 2),
        label = labels
      ) %>%
      gtsummary::add_p(
        test = list(gtsummary::all_categorical() ~ "fisher.test"),
        test.args = list(
          gtsummary::all_categorical() ~ list(simulate.p.value = TRUE),
          gtsummary::all_continuous() ~ list(exact = FALSE)
        ),
        pvalue_fun = function(x) gtsummary::style_pvalue(x, digits = 3)
      ) %>%
      gtsummary::add_q("holm") %>%
      gtsummary::bold_labels() %>%
      gtsummary::modify_table_body(drop_outcome_unknown))
    # format the table
    gt_table <- t %>% tibble::as_tibble()
    tempN_cases <- as.numeric(gsub(",", "", gsub(".*N = ", "", colnames(gt_table)[[2]])))
    tempN_controls <- as.numeric(gsub(",", "", gsub(".*N = ", "", colnames(gt_table)[[3]])))
    suppressWarnings(gt_table <- gt_table %>% tidyr::separate(get(colnames(gt_table)[[2]]),
      sep = ";",
      into = c("N_cases", "%_cases")
    ))
    suppressWarnings(gt_table <- gt_table %>% tidyr::separate(get(colnames(gt_table)[[4]]),
      sep = ";",
      into = c("N_controls", "%_controls")
    ))
    gt_table <- rbind(c("N", tempN_cases, "", tempN_controls, "", "", ""), gt_table)
    # save it to the excel
    if (save_in_excel) {
      writexl::write_xlsx(gt_table, file_name)
    }
  }
  return(gt_table)
}

#' @rdname DiAna-deprecated
#' @inheritParams descriptive
#' @param database For `new_descriptive()`: `"sample"` for the sample data
#'   shipped with DiAna, or the name of a folder in `data/` (a FAERS quarter
#'   such as `"25Q4"`, or `"VigiBase"`) from which the tables are imported.
#' @export
new_descriptive <- function(pids_cases, RG = NULL, drug = NULL,
                            save_in_excel = !missing(file_name), file_name = "Descriptives.xlsx",
                            vars = c(
                              "sex", "Submission", "Reporter",
                              "age_range", "Outcome", "country",
                              "continent", "age_in_years",
                              "wt_in_kgs", "Reactions",
                              "Indications", "Substances", "num_Substances",
                              "year", "role_cod", "time_to_onset"
                            ),
                            list_pids = list(), method = "independence_test",
                            database = "sample") {
  .Deprecated("descriptive", package = "DiAna")
  if (database == "sample") {
    tables <- list(
      temp_demo = DiAna::sample_Demo, temp_drug = DiAna::sample_Drug,
      temp_reac = DiAna::sample_Reac, temp_indi = DiAna::sample_Indi,
      temp_outc = DiAna::sample_Outc, temp_ther = DiAna::sample_Ther
    )
  } else {
    pids_tot <- base::union(pids_cases, RG)
    files <- c(
      temp_demo = "DEMO", temp_drug = "DRUG", temp_reac = "REAC",
      temp_indi = "INDI", temp_outc = "OUTC"
    )
    if ("time_to_onset" %in% vars && !is.null(drug)) files <- c(files, temp_ther = "THER")
    tables <- lapply(files, function(df_name) {
      import(df_name, quarter = database, pids = pids_tot, save_in_environment = FALSE)
    })
  }
  # VigiBase country codes are not in the DiAna country dictionary
  if (database == "VigiBase") vars <- setdiff(vars, "continent")
  do.call(descriptive, c(
    list(
      pids_cases = pids_cases, RG = RG, drug = drug,
      save_in_excel = save_in_excel, file_name = file_name, vars = vars,
      list_pids = list_pids, method = method
    ),
    tables
  ))
}

#' Seriousness outcomes of each report, for descriptive()
#'
#' Returns one row per report with at least one recorded outcome. Reports
#' without any recorded outcome are left out, so that, once joined to all
#' reports, their outcome columns are NA (unknown) rather than "non-serious".
#' @param temp_outc Outc table, already restricted to the reports described.
#' @param outcome "each" (one logical column per outcome) or "most_severe"
#'   (one ordered factor column, `Outcome`).
#' @noRd
describe_outcomes <- function(temp_outc, outcome) {
  # standard FAERS outcome codes, in decreasing order of severity
  outcome_labels <- c(
    DE = "Death", LT = "Life threatening", DS = "Disability",
    RI = "Required intervention", HO = "Hospitalization",
    CA = "Congenital anomaly", OT = "Other serious"
  )
  outc <- unique(temp_outc[, .(primaryid, code = as.character(outc_cod))])
  outc <- outc[!is.na(code)]
  # codes outside the standard list are kept with their code as label, after the standard ones
  other_codes <- setdiff(unique(outc$code), names(outcome_labels))
  outcome_labels <- c(outcome_labels, stats::setNames(other_codes, other_codes))
  outc[, label := factor(outcome_labels[code], levels = unname(outcome_labels), ordered = TRUE)]
  if (outcome == "most_severe") {
    # the most severe outcome is the first level
    return(outc[, .(Outcome = min(label)), by = "primaryid"])
  }
  wide <- data.table(primaryid = unique(outc$primaryid))
  for (lab in intersect(levels(outc$label), as.character(outc$label))) {
    wide[, (lab) := primaryid %in% outc[label == lab]$primaryid]
  }
  wide
}

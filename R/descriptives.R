#' Generate Descriptive Statistics for a Sample
#'
#' This function generates descriptive statistics for a sample of data, including cases and non-cases, and saves the results to an Excel file.
#'
#' @param pids_cases A vector of primary IDs for cases.
#' @param RG A vector of primary IDs: reference group. Default is NULL.
#' @param drug A vector of drug names. Default is NULL.
#' @param file_name The name of the Excel file to save the results. Default is "Descriptives.xlsx". It only works if save_in_excel is TRUE.
#' @param vars A character vector of variable names to include in the analysis.
#' @param list_pids A list of vectors with primary IDs for custom groups whose distribution should be described. Default is an empty list.
#' @param method The method for Chi-square test analysis, either "independence_test" or "goodness_of_fit". Default is "independence_test". It applies only for comparisons between cases and non-cases.
#' @param save_in_excel Whether to save the outcome in an excel. Defaults to TRUE
#' @param temp_demo Demo dataset. Defaults to Demo. Can be se to sample_Demo for testing
#' @param temp_drug Drug dataset. Can be set to sample_Drug for testing
#' @param temp_reac Reac dataset. Can be set to sample_Reac for testing
#' @param temp_indi Indi dataset. Can be set to sample_Indi for testing
#' @param temp_outc Outc dataset. Can be set to sample_Outc for testing
#' @param temp_reac Reac dataset. Can be set to sample_Reac for testing
#' @param temp_ther Ther dataset. Can be set to sample_Ther for testing
#'
#' @return The function generates descriptive statistics as a gt_table and potentially saves them to an Excel file.
#' @importFrom dplyr distinct left_join
#' @importFrom writexl write_xlsx
#' @importFrom tibble as_tibble
#' @importFrom gtsummary add_p add_q all_categorical all_continuous all_continuous2 bold_labels style_pvalue tbl_summary
#' @importFrom here here
#' @importFrom tidyr separate
#' @importFrom readr read_delim
#' @examples
#' pids_cases <- unique(sample_Demo[sex == "M"]$primaryid)
#' RG <- unique(sample_Demo[sex == "M"]$primaryid)
#'
#' # Generate descriptive statistics for cases
#' descriptive(
#'   pids_cases = pids_cases, save_in_excel = FALSE,
#'   temp_demo = sample_Demo, temp_drug = sample_Drug,
#'   temp_reac = sample_Reac, temp_indi = sample_Indi,
#'   temp_outc = sample_Outc, temp_ther = sample_Ther
#' )
#'
#' # Generate descriptive statistics for cases and non-cases
#' descriptive(
#'   pids_cases = pids_cases, RG = RG, save_in_excel = FALSE,
#'   temp_demo = sample_Demo, temp_drug = sample_Drug,
#'   temp_reac = sample_Reac, temp_indi = sample_Indi,
#'   temp_outc = sample_Outc, temp_ther = sample_Ther
#' )
#' @export

descriptive <- function(pids_cases, RG = NULL, drug = NULL,
                        save_in_excel = TRUE, file_name = "Descriptives.xlsx",
                        vars = c(
                          "sex", "Submission", "Reporter",
                          "age_range", "Outcome", "country",
                          "continent", "age_in_years",
                          "wt_in_kgs", "Reactions",
                          "Indications", "Substances", "year", "role_cod", "time_to_onset"
                        ),
                        list_pids = list(), method = "independence_test",
                        temp_demo = Demo, temp_drug = Drug, temp_reac = Reac,
                        temp_indi = Indi, temp_outc = Outc, temp_ther = Ther) {
  # import data
  pids_tot <- base::union(pids_cases, RG)
  temp_demo <- temp_demo[primaryid %in% pids_tot]
  temp_outc <- temp_outc[primaryid %in% pids_tot]
  temp_reac <- temp_reac[primaryid %in% pids_tot]
  temp_indi <- temp_indi[primaryid %in% pids_tot]
  temp_drug <- temp_drug[primaryid %in% pids_tot]
  temp_ther <- temp_ther[primaryid %in% pids_tot]

  temp <- temp_demo
  temp[, sex := ifelse(sex == "F", "Female", ifelse(sex == "M", "Male", NA))]
  temp[, Submission := ifelse(rept_cod %in% c("30DAY", "5DAY", "EXP"), "Expedited",
    ifelse(rept_cod == "PER", "Periodic",
      "Direct"
    )
  )]
  temp[, Reporter := ifelse(occp_cod == "CN", "Consumer",
    ifelse(occp_cod == "MD", "Physician",
      ifelse(occp_cod == "HP", "Healthcare practitioner",
        ifelse(occp_cod == "PH", "Pharmacist",
          ifelse(occp_cod == "LW", "Lawyer",
            ifelse(occp_cod == "OT", "Other",
              NA
            )
          )
        )
      )
    )
  )]
  temp[, age_in_years := age_in_days / 365]
  temp[, age_range := cut(age_in_days, c(0, 28, 730, 4380, 6570, 10950, 18250, 23725, 27375, 31025, 36500, 73000),
    include.lowest = TRUE, right = FALSE,
    labels = c(
      "Neonate (<28d)", "Infant (28d-1y)", "Child (2y-11y)", "Teenager (12y-17y)", "Adult (18y-29y)", "Adult (30y-49y)",
      "Adult (50y-64y)", "Elderly (65y-74y)", "Elderly (75y-84y)", "Elderly (85y-99y)", "Elderly (>99y)"
    )
  )]
  temp <- temp_outc[, .(Outcome = max(outc_cod)), by = "primaryid"][temp, on = "primaryid"]
  temp[is.na(Outcome)]$Outcome <- "Non Serious"
  levels(temp$Outcome) <- c("Other serious", "Congenital anomaly", "Hospitalization", "Required intervention", "Disability", "Life threatening", "Death", "Non Serious")
  temp$Outcome <- factor(temp$Outcome, levels = c("Death", "Life threatening", "Disability", "Required intervention", "Hospitalization", "Congenital anomaly", "Other serious", "Non Serious"), ordered = TRUE)
  temp[, country := ifelse(is.na(as.character(occr_country)), as.character(reporter_country), as.character(occr_country))]
  temp <- dplyr::distinct(country_dictionary[, .(country, continent)][!is.na(country)])[temp, on = "country"]
  temp$country <- as.factor(temp$country)
  temp$continent <- factor(temp$continent, levels = c("North America", "Europe", "Asia", "South America", "Oceania", "Africa"), ordered = TRUE)
  temp <- temp_reac[, .N, by = "primaryid"][, .(primaryid, Reactions = N)][temp, on = "primaryid"]
  temp <- temp_drug[, .N, by = "primaryid"][, .(primaryid, Substances = N)][temp, on = "primaryid"]
  temp <- temp_indi[, .N, by = "primaryid"][, .(primaryid, Indications = N)][temp, on = "primaryid"]
  temp_tto <- temp_drug[temp_ther, on = c("primaryid", "drug_seq")][substance %in% drug]
  suppressWarnings(temp_tto[, role_cod := max(role_cod), by = "primaryid"])
  temp_tto <- temp_tto[!is.na(time_to_onset) & time_to_onset >= 0]
  suppressWarnings(temp_tto <- temp_tto[, .(time_to_onset = max(time_to_onset)), by = "primaryid"])
  temp <- temp_tto[temp, on = "primaryid"]
  temp$time_to_onset <- as.numeric(temp$time_to_onset)
  temp[, year := as.factor(ifelse(!is.na(event_dt),
    as.numeric(substr(event_dt, 1, 4)), ifelse(!is.na(init_fda_dt),
      as.numeric(substr(init_fda_dt, 1, 4)), as.numeric(substr(fda_dt, 1, 4))
    )
  ))]
  # add the max role_cod for the drug
  if (!is.null(drug)) {
    temp_drug <- temp_drug[primaryid %in% pids_tot][substance %in% drug][
      , role_cod := factor(role_cod, levels = c("C", "I", "SS", "PS"), ordered = TRUE)
    ][
      , .(role_cod = max(role_cod)),
      by = "primaryid"
    ]
    suppressMessages(temp <- dplyr::left_join(temp, temp_drug))
  } else {
    vars <- setdiff(vars, c("role_cod", "time_to_onset"))
    warning("Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated")
  }

  # descriptive only cases
  if (is.null(RG)) {
    # select the vars
    temp <- temp[, ..vars]
    t <- temp %>%
      gtsummary::tbl_summary(statistic = list(
        gtsummary::all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}]",
        gtsummary::all_categorical() ~ "{n};{p}"
      ), digits = colnames(temp) ~ c(0, 2)) # %>%
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
        digits = everything() ~ c(0, 2)
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
      gtsummary::bold_labels())
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

#' Generate Descriptive Statistics for a Sample
#'
#' This function generates descriptive statistics for a sample of data, including cases and non-cases, and saves the results to an Excel file.
#'
#' @param pids_cases A vector of primary IDs for cases.
#' @param RG A vector of primary IDs: reference group. Default is NULL.
#' @param drug A vector of drug names. Default is NULL.
#' @param file_name The name of the Excel file to save the results. Default is "Descriptives.xlsx". It only works if save_in_excel is TRUE.
#' @param vars A character vector of variable names to include in the analysis.
#' @param list_pids A list of vectors with primary IDs for custom groups whose distribution should be described. Default is an empty list.
#' @param method The method for Chi-square test analysis, either "independence_test" or "goodness_of_fit". Default is "independence_test". It applies only for comparisons between cases and non-cases.
#' @param save_in_excel Whether to save the outcome in an excel. Defaults to TRUE
#' @param database Database on which to run the analysis. By default "sample".
#'
#' @return The function generates descriptive statistics as a gt_table and potentially saves them to an Excel file.
#' @importFrom dplyr distinct left_join
#' @importFrom writexl write_xlsx
#' @importFrom tibble as_tibble
#' @importFrom gtsummary add_p add_q all_categorical all_continuous all_continuous2 bold_labels style_pvalue tbl_summary
#' @importFrom here here
#' @importFrom tidyr separate
#' @importFrom readr read_delim
#' @examples
#' pids_cases <- unique(sample_Demo[sex == "M"]$primaryid)
#' RG <- unique(sample_Demo[sex == "M"]$primaryid)
#'
#' # Generate descriptive statistics for cases
#' new_descriptive(
#'   pids_cases = pids_cases, save_in_excel = FALSE
#' )
#'
#' # Generate descriptive statistics for cases and non-cases
#' new_descriptive(
#'   pids_cases = pids_cases, RG = RG, save_in_excel = FALSE
#' )
#' @export

new_descriptive <- function(pids_cases, RG = NULL, drug = NULL,
                            save_in_excel = TRUE, file_name = "Descriptives.xlsx",
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
  # import data
  pids_tot <- base::union(pids_cases, RG)
  if (database == "sample") {
    Demo <- DiAna::sample_Demo[primaryid %in% pids_tot]

    Drug <- DiAna::sample_Drug[primaryid %in% pids_tot]

    Reac <- DiAna::sample_Reac[primaryid %in% pids_tot]

    Indi <- DiAna::sample_Indi[primaryid %in% pids_tot]

    Outc <- DiAna::sample_Outc[primaryid %in% pids_tot]

    Ther <- DiAna::sample_Ther[primaryid %in% pids_tot]
  } else {
    DiAna::import("DEMO", quarter = database, pids = pids_tot)

    DiAna::import("DRUG", quarter = database, pids = pids_tot)

    DiAna::import("REAC", quarter = database, pids = pids_tot)

    DiAna::import("INDI", quarter = database, pids = pids_tot)

    DiAna::import("OUTC", quarter = database, pids = pids_tot)

    if ("time_to_onset" %in% vars) DiAna::import("THER", quarter = database, pids = pids_tot)
  }
  temp <- Demo
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
  temp_outc <- Outc[, `:=`(outc_cod, ifelse(outc_cod == "OT", "Other serious",
    ifelse(outc_cod == "CA", "Congenital anomaly",
      ifelse(outc_cod == "HO", "Hospitalization",
        ifelse(outc_cod == "RI", "Required intervention",
          ifelse(outc_cod == "DS", "Disability",
            ifelse(outc_cod == "LT", "Life threatening",
              ifelse(outc_cod == "DE", "Death", outc_cod)
            )
          )
        )
      )
    )
  ))]

  vars <- union(setdiff(vars, "Outcome"), unique(temp_outc$outc_cod))

  temp_outc <- temp_outc[, value := 1] %>% tidyr::pivot_wider(names_from = outc_cod, values_from = value, values_fill = 0)

  temp <- setDT(temp_outc)[temp, on = "primaryid"]
  temp[, country := ifelse(is.na(as.character(occr_country)), as.character(reporter_country), as.character(occr_country))]
  if (database != "VigiBase") {
    temp <- dplyr::distinct(country_dictionary[, .(country, continent)][!is.na(country)])[temp, on = "country"]
    temp$country <- as.factor(temp$country)
    temp$continent <- factor(temp$continent, levels = c("North America", "Europe", "Asia", "South America", "Oceania", "Africa"), ordered = TRUE)
  }
  temp <- Reac[, .N, by = "primaryid"][, .(primaryid, Reactions = N)][temp, on = "primaryid"]
  temp <- Drug[, .N, by = "primaryid"][, .(primaryid, Substances = N)][temp, on = "primaryid"]
  if ("num_Substances" %in% vars) {
    temp[, num_Substances := ifelse(Substances == 1, "1",
      ifelse(Substances == 2, "2",
        ifelse(Substances > 2 & Substances <= 5, "3-5", ">5")
      )
    )]
    temp$num_Substances <- factor(temp$num_Substances, levels = c("1", "2", "3-5", ">5"))
  }
  temp <- Indi[, .N, by = "primaryid"][, .(primaryid, Indications = N)][temp, on = "primaryid"]
  if ("time_to_onset" %in% vars) {
    temp_tto <- Drug[Ther, on = c("primaryid", "drug_seq")][substance %in% drug]
    suppressWarnings(temp_tto[, role_cod := max(role_cod), by = "primaryid"])
    temp_tto <- temp_tto[!is.na(time_to_onset) & time_to_onset >= 0]
    suppressWarnings(temp_tto <- temp_tto[, .(time_to_onset = max(time_to_onset)), by = "primaryid"])
    temp <- temp_tto[temp, on = "primaryid"]
    temp$time_to_onset <- as.numeric(temp$time_to_onset)
  }
  if ("year" %in% vars) {
    temp[, year := as.factor(ifelse(!is.na(event_dt),
      as.numeric(substr(event_dt, 1, 4)), ifelse(!is.na(init_fda_dt),
        as.numeric(substr(init_fda_dt, 1, 4)), as.numeric(substr(fda_dt, 1, 4))
      )
    ))]
  }
  # add the max role_cod for the drug
  if (!is.null(drug)) {
    temp_drug <- temp_drug[primaryid %in% pids_tot][substance %in% drug][
      , role_cod := factor(role_cod, levels = c("C", "I", "SS", "PS"), ordered = TRUE)
    ][
      , .(role_cod = max(role_cod)),
      by = "primaryid"
    ]
    suppressMessages(temp <- dplyr::left_join(temp, temp_drug))
  } else {
    vars <- setdiff(vars, c("role_cod", "time_to_onset"))
    warning("Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated")
  }

  # descriptive only cases
  if (is.null(RG)) {
    # select the vars
    temp <- temp[, ..vars]
    t <- temp %>%
      gtsummary::tbl_summary(statistic = list(
        gtsummary::all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}]",
        gtsummary::all_categorical() ~ "{n};{p}"
      ), digits = colnames(temp) ~ c(0, 2)) # %>%
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
        digits = everything() ~ c(0, 2)
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
      gtsummary::bold_labels())
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

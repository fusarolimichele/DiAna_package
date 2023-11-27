#' Generate Descriptive Statistics for a Sample
#'
#' This function generates descriptive statistics for a sample of data, including cases and non-cases, and saves the results to an Excel file.
#'
#' @param pids_cases A vector of primary IDs for cases.
#' @param RG A vector of primary IDs: reference group. Default is NULL.
#' @param drug A vector of drug names. Default is NULL.
#' @param file_name The name of the Excel file to save the results. Default is "Descriptives.xlsx".
#' @param vars A character vector of variable names to include in the analysis.
#' @param list_pids A list of vectors with primary IDs for custom groups whose distribution should be described. Default is an empty list.
#' @param method The method for Chi-square test analysis, either "independence_test" or "goodness_of_fit". Default is "independence_test". It applies only for comparisons between cases and non-cases.
#' @param quarter The quarter for data import. Default is FAERS_version, which we recommend to provide at the beginning of the script.
#'
#' @return The function generates descriptive statistics and saves them to an Excel file.
#'
#' @examples
#' \dontrun{
#' import("DEMO", quarter = "23Q1")
#' pids_cases <- sample(Demo$primaryid, 100)
#' RG <- sample(Demo[!primaryid %in% pids_cases]$primaryid, 100)
#'
#' # Generate descriptive statistics for cases
#' descriptive(pids_cases = pids_cases)
#' descriptive(pids_cases = pids_cases, drug = "paracetamol")
#'
#' # Generate descriptive statistics for cases and non-cases
#' descriptive(pids_cases = pids_cases, RG = RG)
#' descriptive(pids_cases = pids_cases, RG = RG, drug = "paracetamol")
#' }
#' @export

descriptive <- function(pids_cases, RG = NULL, drug = NULL, file_name = "Descriptives.xlsx",
                        vars = c(
                          "sex", "Submission", "Reporter",
                          "age_range", "Outcome", "country",
                          "continent", "age_in_years",
                          "wt_in_kgs", "Reactions",
                          "Indications", "Substances", "year", "role_cod", "time_to_onset"
                        ),
                        list_pids = list(), method = "independence_test",
                        quarter = FAERS_version) {
  # import data if now already uploaded
  pids_tot <- union(pids_cases, RG)
  temp <- import("DEMO", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)
  temp_outc <- import("OUTC", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)
  temp_reac <- import("REAC", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)
  temp_indi <- import("INDI", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)
  temp_drug <- import("DRUG", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)
  temp_ther <- import("THER", quarter = quarter, pids = pids_tot, save_in_environment = FALSE)

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
      "Neonate (<28d)", "Infant (28d-<2y)", "Child (2y-<12y)", "Teenager (12y-<18y)", "Adult (18y-<30y)", "Adult (30y-<50y)",
      "Adult (50y-<65y)", "Elderly (65y-<75y)", "Elderly (75y-<85y)", "Elderly (85y-<100y)", "Elderly (≥100y)"
    )
  )]
  temp <- temp_outc[, .(Outcome = max(outc_cod)), by = "primaryid"][temp, on = "primaryid"]
  temp[is.na(Outcome)]$Outcome <- "Non Serious"
  levels(temp$Outcome) <- c("Other serious", "Congenital anomaly", "Hospitalization", "Required intervention", "Disability", "Life threatening", "Death", "Non Serious")
  temp$Outcome <- factor(temp$Outcome, levels = c("Death", "Life threatening", "Disability", "Required intervention", "Hospitalization", "Congenital anomaly", "Other serious", "Non Serious"), ordered = TRUE)
  suppressMessages(country_codes <- setDT(read_delim(paste0(paste0(here(), "/external_sources/Countries.csv")), ";", escape_double = FALSE, trim_ws = TRUE, show_col_types = FALSE))[
    , .(country = Country_Name, continent = Continent_Name)
  ][!is.na(country)] %>% distinct())
  temp[, country := ifelse(is.na(as.character(occr_country)), as.character(reporter_country), as.character(occr_country))]
  temp <- country_codes[temp, on = "country"]
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
    suppressMessages(temp <- left_join(temp, temp_drug))
  } else {
    vars <- setdiff(vars, c("role_cod", "time_to_onset"))
    print("Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated")
  }

  # descriptive only cases
  if (is.null(RG)) {
    # select the vars
    temp <- temp[, ..vars]
    t <- temp %>%
      tbl_summary(statistic = list(
        all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}]",
        all_categorical() ~ "{n};{p}"
      ), digits = colnames(temp) ~ c(0, 2)) # %>%
    # format the table
    gt_table <- t %>% as_tibble()
    tempN_cases <- as.numeric(gsub("\\*\\*", "", gsub(".*N = ", "", colnames(gt_table)[[2]])))
    suppressWarnings(gt_table <- gt_table %>% separate(get(colnames(gt_table)[[2]]),
      sep = ";",
      into = c("N_cases", "%_cases")
    ))
    gt_table <- rbind(c("N", tempN_cases, ""), gt_table)
    # save it to the excel
    writexl::write_xlsx(gt_table, file_name)
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
      tbl_summary(
        by = Group, statistic = list(
          all_continuous() ~ "{median} ({p25}-{p75}) [{min}-{max}] {p_nonmiss}",
          all_continuous2() ~ "{median} ({p25}-{p75}) [{min}-{max}] {p_nonmiss}",
          all_categorical() ~ "{n};{p}"
        ),
        digits = colnames(temp) ~ c(0, 2)
      ) %>%
      add_p(
        test = list(all_categorical() ~ "fisher.test.simulate.p.values"), # this applies the custom test to all categorical variables
        pvalue_fun = function(x) style_pvalue(x, digits = 3)
      ) %>%
      add_q("holm") %>%
      bold_labels())
    # format the table
    gt_table <- t %>% as_tibble()
    tempN_cases <- as.numeric(gsub(",", "", gsub(".*N = ", "", colnames(gt_table)[[2]])))
    tempN_controls <- as.numeric(gsub(",", "", gsub(".*N = ", "", colnames(gt_table)[[3]])))
    suppressWarnings(gt_table <- gt_table %>% separate(get(colnames(gt_table)[[2]]),
      sep = ";",
      into = c("N_cases", "%_cases")
    ))
    suppressWarnings(gt_table <- gt_table %>% separate(get(colnames(gt_table)[[4]]),
      sep = ";",
      into = c("N_controls", "%_controls")
    ))
    gt_table <- rbind(c("N", tempN_cases, "", tempN_controls, "", "", ""), gt_table)
    # save it to the excel
    writexl::write_xlsx(gt_table, file_name)
  }
}

#' Compute Fisher's Exact Test with Simulated p-values
#'
#' This function performs Fisher's Exact Test with simulated p-values for association between two categorical variables.
#'
#' @param data A data frame containing the variables of interest.
#' @param variable The name of the first categorical variable.
#' @param by The name of the second categorical variable.
#' @param ... Additional arguments to be passed to the \code{\link[stats:fisher.test]{fisher.test}} function.
#'
#' @return A list containing the following elements:
#' \describe{
#'   \item{p}{The simulated p-value for the Fisher's Exact Test.}
#'   \item{test}{The name of the test method, which is "Fisher's Exact Test with Simulation".}
#' }
#'
#' @seealso \code{\link[stats:fisher.test]{fisher.test}} for more information on Fisher's Exact Test.
#'
#' @export

fisher.test.simulate.p.values <- function(data, variable, by, ...) {
  result <- list()
  test_results <- stats::fisher.test(data[[variable]], data[[by]], simulate.p.value = TRUE)
  result$p <- test_results$p.value
  result$test <- test_results$method
  result
}

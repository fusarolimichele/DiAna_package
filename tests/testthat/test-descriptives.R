sample_tables <- list(
  temp_demo = sample_Demo, temp_drug = sample_Drug, temp_reac = sample_Reac,
  temp_indi = sample_Indi, temp_outc = sample_Outc, temp_ther = sample_Ther
)
outcome_labels <- c(
  "Death", "Life threatening", "Disability", "Required intervention",
  "Hospitalization", "Congenital anomaly", "Other serious"
)
# rows of a descriptive table, by label
row_of <- function(tab, label) as.data.frame(tab)[as.data.frame(tab)[[1]] == label, ]

test_that("Descriptive function warns", {
  expect_warning(descriptive(
    pids_cases = sample_Drug[substance == "adalimumab"]$primaryid,
    temp_demo = sample_Demo, temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_indi = sample_Indi, temp_outc = sample_Outc, temp_ther = sample_Ther,
    save_in_excel = FALSE
  ))
})
test_that("Descriptive function works with cases", {
  expect_equal(
    descriptive(
      pids_cases = sample_Drug[substance == "adalimumab"]$primaryid,
      temp_demo = sample_Demo, temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_indi = sample_Indi, temp_outc = sample_Outc, temp_ther = sample_Ther,
      save_in_excel = FALSE, drug = "adalimumab"
    )$N_cases,
    c(
      "45", NA, "29", "11", "5", NA, "4", "20", "21", NA, "25", "3",
      "3", "11", "3", NA, "0", "0", "0", "0", "3", "4", "11", "1",
      "0", "0", "0", "26", "21", "10", "11", NA, "1", "1", "1", "3",
      "1", "1", "1", "1", "35", NA, "37", "7", "0", "0", "1", "0",
      "51 (42.00-57) [21.00-69]", "26", NA, "2", "1", "1", "1", "1",
      "1", "1", "2", "1", "34", NA, "17", "13", "6", "4", "4", "1",
      NA, "24", "7", "4", "3", "3", "2", "1", "1", "2 (1.00-4) [1.00-18]",
      NA, "22", "7", "9", "7", NA, "1", "1", "1", "3", "1", "3", "1",
      "6", "4", "4", "2", "4", "3", "4", "2", "4", "1", NA, "1", "0",
      "3", "41", "62 (8.00-202) [1.00-882]", "34"
    )
  )
})
test_that("Descriptive function works with cases and RG", {
  expect_equal(
    descriptive(
      pids_cases = sample_Demo[sex == "M"]$primaryid,
      RG = sample_Demo[sex == "F"]$primaryid,
      temp_demo = sample_Demo, temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_indi = sample_Indi, temp_outc = sample_Outc, temp_ther = sample_Ther,
      save_in_excel = FALSE, drug = "adalimumab"
    )$N_controls[1:10],
    c("538", NA, "538", "0", NA, "39", "244", "255", NA, "254")
  )
})

test_that("Outcomes: reports without any outcome are excluded from the denominator", {
  pids <- unique(sample_Demo[sex == "F"]$primaryid)
  tab <- suppressWarnings(do.call(descriptive, c(list(pids_cases = pids, vars = "Outcome"), sample_tables)))
  outc <- unique(sample_Outc[primaryid %in% pids, .(primaryid, outc_cod)])
  n_recorded <- length(unique(outc$primaryid))

  recorded <- row_of(tab, "Seriousness recorded")
  expect_equal(as.numeric(recorded$N_cases), n_recorded)
  expect_equal(as.numeric(recorded$`%_cases`), round(100 * n_recorded / length(pids), 2))

  death <- row_of(tab, "Death")
  n_death <- length(unique(outc[outc_cod == "DE"]$primaryid))
  expect_equal(as.numeric(death$N_cases), n_death)
  expect_equal(as.numeric(death$`%_cases`), round(100 * n_death / n_recorded, 2))

  # no "Non Serious" category, and no "Unknown" rows inside the outcome block
  expect_false("Non Serious" %in% as.data.frame(tab)[[1]])
  labels <- as.data.frame(tab)[[1]]
  block <- seq(which(labels == "Seriousness recorded"), max(which(labels %in% outcome_labels)))
  expect_false("Unknown" %in% labels[block])
})

test_that("Outcomes: 'each' counts every outcome, 'most_severe' only the worst", {
  # one report with death and hospitalization, one with hospitalization only,
  # one without any outcome
  pids <- sample_Demo$primaryid[1:3]
  outc <- data.table::data.table(
    primaryid = pids[c(1, 1, 2)],
    outc_cod = factor(c("DE", "HO", "HO"), levels = levels(sample_Outc$outc_cod), ordered = TRUE)
  )
  tables <- modifyList(sample_tables, list(temp_outc = outc))
  args <- list(pids_cases = pids, vars = "Outcome")

  each <- suppressWarnings(do.call(descriptive, c(args, tables)))
  expect_equal(row_of(each, "Seriousness recorded")$N_cases, "2")
  expect_equal(row_of(each, "Death")$N_cases, "1")
  expect_equal(row_of(each, "Death")$`%_cases`, "50.00")
  expect_equal(row_of(each, "Hospitalization")$N_cases, "2")
  expect_equal(row_of(each, "Hospitalization")$`%_cases`, "100.00")

  worst <- suppressWarnings(do.call(descriptive, c(args, outcome = "most_severe", tables)))
  expect_equal(row_of(worst, "Death")$N_cases, "1")
  expect_equal(row_of(worst, "Hospitalization")$N_cases, "1")
  expect_equal(row_of(worst, "Hospitalization")$`%_cases`, "50.00")
})

test_that("descriptive() does not modify the tables it receives", {
  demo <- data.table::copy(sample_Demo)
  outc <- data.table::copy(sample_Outc)
  tables <- modifyList(sample_tables, list(temp_demo = demo, temp_outc = outc))
  suppressWarnings(do.call(descriptive, c(list(pids_cases = sample_Demo$primaryid), tables)))
  expect_identical(demo, sample_Demo)
  expect_identical(outc, sample_Outc)
})

test_that("new_descriptive() is deprecated and gives the same table as descriptive()", {
  pids <- unique(sample_Drug[substance == "adalimumab"]$primaryid)
  expect_warning(
    old <- new_descriptive(pids, drug = "adalimumab"),
    "descriptive",
    class = "deprecatedWarning"
  )
  expect_equal(old, do.call(descriptive, c(list(pids_cases = pids, drug = "adalimumab"), sample_tables)))
})

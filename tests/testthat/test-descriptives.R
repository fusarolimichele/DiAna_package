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
      "0", "0", "0", "26", NA, "0", "0", "0", "0", "10", "0", "11",
      "24", NA, "1", "1", "1", "3", "1", "1", "1", "1", "35", NA, "37",
      "7", "0", "0", "1", "0", "51 (42.00-57) [21.00-69]", "26", NA,
      "2", "1", "1", "1", "1", "1", "1", "2", "1", "34", NA, "17",
      "13", "6", "4", "4", "1", NA, "24", "7", "4", "3", "3", "2",
      "1", "1", "2 (1.00-4) [1.00-18]", NA, "1", "1", "1", "3", "1",
      "3", "1", "6", "4", "4", "2", "4", "3", "4", "2", "4", "1", NA,
      "1", "0", "3", "41", "62 (8.00-202) [1.00-882]", "34"
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
    )$N_cases,
    c(
      "355", NA, "0", "355", NA, "24", "181", "150", NA, "163", "20",
      "14", "38", "17", "85", "18", NA, "0", "2", "9", "6", "12", "50",
      "70", "41", "17", "3", "0", "145", NA, "41", "12", "9", "2",
      "71", "0", "85", "135", NA, "1", "3", "1", "1", "3", "9", "1",
      "3", "1", "0", "1", "0", "1", "1", "0", "1", "0", "0", "8", "14",
      "1", "3", "1", "4", "9", "2", "1", "2", "2", "1", "2", "0", "0",
      "0", "0", "0", "1", "0", "1", "2", "2", "1", "2", "0", "11",
      "252", "6", NA, "263", "52", "22", "6", "4", "2", "6", "55 (41.00-67) [0.11-86] 59.15",
      "145", "81 (67.00-99) [15.00-188] 22.82", "274", "2 (1.00-4) [1.00-27] 100.00",
      "1 (1.00-3) [1.00-43] 89.86", "36", "2 (1.00-5) [1.00-62] 100.00",
      NA, "0", "0", "1", "2", "0", "3", "5", "5", "3", "5", "16", "8",
      "10", "13", "18", "19", "13", "21", "32", "25", "34", "22", "38",
      "39", "20", "3", NA, "0", "0", "0", "11", "344", "174 (37.00-202) [1.00-882] 1.41",
      "350"
    )
  )
})

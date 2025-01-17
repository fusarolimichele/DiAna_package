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
    )$N_controls[1:10],
    c("538", NA, "538", "0", NA, "39", "244", "255", NA, "254")
  )
})

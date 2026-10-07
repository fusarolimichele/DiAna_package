test_that("Retrieve cases works", {
  expect_equal(retrieve(
    pids = unique(sample_Drug[substance == "adalimumab"]$primaryid),
    temp_reac = sample_Reac, temp_drug = sample_Drug,
    temp_outc = sample_Outc, temp_demo = sample_Demo,
    temp_demo_supp = sample_Demo_Supp, temp_ther = sample_Ther,
    temp_doses = sample_Doses, temp_indi = sample_Indi,
    temp_drug_name = sample_Drug_Name,
    temp_drug_supp = sample_Drug_Supp,
    save_in_excel = FALSE
  )$drug_info$dose, c(
    "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
    "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
    "  ", "  ", "  ", "  ", "  ", "40 MG QOW", "40 MG QOW", "  ",
    "  ", "  ", "  ", "  ", "  ", "  ", "40 MG QOW", "40 MG QOW",
    "15 MG QW", "40 MG QOW", "  ", "40 MG ", "40 MG QOW", "40 MG QOW",
    "  ", "40 MG QOW", "9 MG QD", "40 MG QW", "40 MG QW", "  ", "  ",
    "40 MG QOW", "40 MG QOW", "500 MG BID", "200 MG QD", "10 MG ",
    "1 MG QD", "25 MG QD", "40 MG QOW", "  ", "40 MG QOW", "  ",
    "  ", "  ", "  ", "  ", "  ", "  ", "  TID", "20 MG QD", "35 MG QW",
    "  BIW", "  ", "  ", "40 MG QOW", "40 MG ", "  ", "  ", "  ",
    "  ", "  ", "  ", "  ", "  ", "  ", "  ", "11 MG QD", "  QOW",
    "  ", "  ", "  ", "  ", "10 MG ", "  ", "  ", "  ", "  ", "  ",
    "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
    "40 MG QW", "  ", "  ", "  ", "  ", "40 MG ", "40 MG QOW", "40 MG QCycle",
    "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ", "  ",
    "40 MG QOW", "40 MG ", "  ", "  ", "  "
  ))
})

test_that("Retrieve cases works with MedDRA and ATC tables", {
  pids <- unique(sample_Drug[substance == "adalimumab"]$primaryid)
  fake_meddra <- data.table::data.table(pt = unique(sample_Reac$pt))
  fake_meddra[, `:=`(hlgt = paste0("hlgt_", substr(pt, 1, 1)), soc = "soc_a")]
  fake_atc <- data.table::data.table(
    substance = "adalimumab",
    code = c("L04AB04", "X99XX99"), primary_code = "L04AB04",
    Class1 = c("Antineoplastic and immunomodulating agents", "Fake class"),
    Class3 = c("Immunosuppressants", "Fake class 3")
  )
  res <- retrieve(
    pids = pids,
    temp_reac = sample_Reac, temp_drug = sample_Drug,
    temp_outc = sample_Outc, temp_demo = sample_Demo,
    temp_demo_supp = sample_Demo_Supp, temp_ther = sample_Ther,
    temp_doses = sample_Doses, temp_indi = sample_Indi,
    temp_drug_name = sample_Drug_Name,
    temp_drug_supp = sample_Drug_Supp,
    temp_meddra = fake_meddra, temp_atc = fake_atc,
    save_in_excel = FALSE
  )
  expect_equal(nrow(res$general_info), length(pids))
  # only the primary ATC code is used, so the fake secondary class never appears
  expect_false(any(grepl("Fake", res$general_info$substance)))
  expect_true(all(grepl("adalimumab", res$general_info$substance)))
})

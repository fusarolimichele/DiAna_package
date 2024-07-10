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

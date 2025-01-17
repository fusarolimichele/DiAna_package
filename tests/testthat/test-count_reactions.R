test_that("Reporting_rate works for reactions", {
  expect_equal(
    head(as.character(reporting_rates(sample_Drug[substance == "adalimumab"]$primaryid,
      temp_reac = sample_Reac, temp_drug = sample_Drug,
      temp_indi = sample_Indi
    )$pt)),
    c(
      "drug ineffective", "nausea", "rheumatoid arthritis",
      "crohn's disease",
      "alopecia", "back pain"
      )
  )
})

test_that("Reporting_rate works for indications", {
  expect_equal(
    head(as.character(reporting_rates(sample_Drug[substance == "adalimumab"]$primaryid,
      "indication",
      drug_indi = "adalimumab",
      temp_reac = sample_Reac, temp_drug = sample_Drug,
      temp_indi = sample_Indi
    )$pt)),
    c("rheumatoid arthritis", "crohn's disease", "psoriatic arthropathy",
      "psoriasis", "ankylosing spondylitis", "hidradenitis")
  )
})

test_that("Reporting_rate works for drugs", {
  expect_equal(
    head(as.character(reporting_rates(sample_Drug[substance == "adalimumab"]$primaryid,
      "substance",
      temp_reac = sample_Reac, temp_drug = sample_Drug,
      temp_indi = sample_Indi
    )$substance)),
    c("adalimumab", "methotrexate", "prednisone", "etanercept", "vitamin b9",
      "cetirizine")
  )
})

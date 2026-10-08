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
    c(
      "rheumatoid arthritis", "crohn's disease", "psoriatic arthropathy",
      "psoriasis", "ankylosing spondylitis", "hidradenitis"
    )
  )
})

test_that("Reporting_rate works for drugs", {
  expect_equal(
    head(as.character(reporting_rates(sample_Drug[substance == "adalimumab"]$primaryid,
      "substance",
      temp_reac = sample_Reac, temp_drug = sample_Drug,
      temp_indi = sample_Indi
    )$substance)),
    c(
      "adalimumab", "methotrexate", "prednisone", "etanercept", "vitamin b9",
      "cetirizine"
    )
  )
})

# Small fake dictionaries built from the sample terms, so no licensed file is needed
fake_meddra <- unique(data.table::data.table(pt = c(sample_Reac$pt, sample_Indi$indi_pt)))
fake_meddra[, `:=`(
  hlt = paste("hlt", substr(pt, 1, 2)), hlgt = paste("hlgt", substr(pt, 1, 1)),
  soc = ifelse(substr(pt, 1, 1) < "m", "soc a-l", "soc m-z")
)]
fake_atc <- unique(data.table::data.table(substance = sample_Drug$substance))
fake_atc[, `:=`(
  code = paste0("X", seq_len(.N)), primary_code = paste0("X", seq_len(.N)),
  Class4 = paste("c4", substr(substance, 1, 2)), Class3 = paste("c3", substr(substance, 1, 1)),
  Class2 = "c2", Class1 = "c1"
)]

test_that("reporting_rates() uses a MedDRA passed in or loaded, without reading the file", {
  local_mocked_bindings(import_MedDRA = function(...) stop("MedDRA file read"))
  pids <- unique(sample_Drug[substance == "paracetamol"]$primaryid)
  res <- reporting_rates(pids, "reaction", "soc", temp_reac = sample_Reac, temp_meddra = fake_meddra)
  expect_setequal(res$soc, c("soc a-l", "soc m-z"))

  assign("MedDRA", fake_meddra, envir = globalenv())
  on.exit(rm("MedDRA", envir = globalenv()), add = TRUE)
  expect_equal(reporting_rates(pids, "reaction", "soc", temp_reac = sample_Reac), res)
})

test_that("reporting_rates() reads MedDRA from file only when it is not available", {
  skip_if(exists("MedDRA"))
  read <- 0
  local_mocked_bindings(import_MedDRA = function(...) {
    read <<- read + 1
    fake_meddra
  })
  reporting_rates(sample_Demo$primaryid, "reaction", "hlgt", temp_reac = sample_Reac)
  expect_equal(read, 1)
})

test_that("hierarchical_rates() reads each dictionary at most once and accepts case tables", {
  skip_if(exists("MedDRA") || exists("ATC"))
  read <- c(MedDRA = 0, ATC = 0)
  local_mocked_bindings(
    import_MedDRA = function(...) {
      read[["MedDRA"]] <<- read[["MedDRA"]] + 1
      fake_meddra
    },
    import_ATC = function(...) {
      read[["ATC"]] <<- read[["ATC"]] + 1
      fake_atc
    }
  )
  pids <- sample_Demo$primaryid
  reac <- hierarchical_rates(pids, "reaction", temp_reac = sample_Reac)
  subst <- hierarchical_rates(pids, "substance", temp_drug = sample_Drug)
  expect_equal(read, c(MedDRA = 1, ATC = 1))
  expect_named(reac, c("label_soc", "label_hlgt", "label_hlt", "label_pt"))
  expect_named(subst, c("label_Class1", "label_Class2", "label_Class3", "label_Class4", "label_substance"))
  expect_equal(nrow(reac), length(unique(sample_Reac[primaryid %in% pids]$pt)))
})

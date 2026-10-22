test_that("Missing workspace tables give a clear error naming the fix", {
  skip_if(exists("Drug") || exists("Reac"))
  expect_error(
    disproportionality_analysis("paracetamol", "overdose"),
    "`temp_drug` was not supplied.*`Drug`.*import\\(\"DRUG\"\\).*temp_drug = sample_Drug"
  )
  expect_error(
    disproportionality_analysis("paracetamol", "overdose", temp_drug = sample_Drug),
    "`temp_reac` was not supplied.*import\\(\"REAC\"\\)"
  )
})

test_that("Only the tables a call actually uses are required", {
  skip_if(exists("Indi") || exists("Drug"))
  # entity = "reaction" uses temp_reac only: no Indi or Drug needed
  expect_no_error(network_analysis(
    pids = sample_Demo[sex == "F"]$primaryid,
    entity = "reaction", temp_reac = sample_Reac
  ))
  expect_error(
    network_analysis(pids = sample_Demo$primaryid, entity = "indication"),
    "`temp_indi`.*import\\(\"INDI\"\\)"
  )
})

test_that("MedDRA-level analyses explain how to load MedDRA", {
  skip_if(exists("MedDRA"))
  expect_error(
    disproportionality_analysis("paracetamol", "overdose",
      temp_drug = sample_Drug, temp_reac = sample_Reac, meddra_level = "hlt"
    ),
    "`MedDRA` was not found.*import_MedDRA\\(\\)"
  )
})

test_that("disproportionality_trend() does not modify the Demo table it receives", {
  demo <- data.table::copy(sample_Demo)
  disproportionality_trend("adalimumab", "injection site pain",
    temp_drug = sample_Drug, temp_reac = sample_Reac, temp_demo = demo
  )
  expect_identical(names(demo), names(sample_Demo))
  expect_false("period" %in% names(demo))
})

test_that("No file is written unless a file name or saving is requested", {
  dir <- tempfile()
  dir.create(dir)
  old <- setwd(dir)
  on.exit(setwd(old), add = TRUE)
  pids <- unique(sample_Drug[substance == "adalimumab"]$primaryid)
  args <- list(
    pids = pids, temp_reac = sample_Reac, temp_drug = sample_Drug,
    temp_outc = sample_Outc, temp_demo = sample_Demo,
    temp_demo_supp = sample_Demo_Supp, temp_ther = sample_Ther,
    temp_doses = sample_Doses, temp_indi = sample_Indi,
    temp_drug_name = sample_Drug_Name, temp_drug_supp = sample_Drug_Supp
  )
  do.call(retrieve, args)
  expect_length(list.files(dir), 0)
  do.call(retrieve, c(args, file_name = "cases"))
  expect_setequal(list.files(dir), c("cases.xlsx", "cases_drug.xlsx"))
})

test_that("Fix_DiAna_dictionary_locally() replaces, rather than duplicates, the fixed drugs", {
  changes <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(data.frame(drugname = "humira", substance = "adalimumab_fixed"), changes)
  res <- Fix_DiAna_dictionary_locally(changes,
    temp_drug = sample_Drug, temp_drug_name = sample_Drug_Name
  )
  key <- c("primaryid", "drug_seq")
  fixed <- unique(sample_Drug_Name[drugname == "humira", ..key])
  expect_equal(nrow(res), nrow(sample_Drug))
  expect_true(all(res[fixed, on = key]$substance == "adalimumab_fixed"))
  expect_equal(nrow(res[!fixed, on = key]), nrow(sample_Drug[!fixed, on = key]))
})

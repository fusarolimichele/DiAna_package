# A temporary DiAna project with the sample data saved as quarter "99Q1"
fake_root <- tempfile("diana_")
dir.create(file.path(fake_root, "data", "99Q1"), recursive = TRUE)
fake_tables <- list(
  DEMO = sample_Demo, DRUG = sample_Drug, REAC = sample_Reac,
  INDI = sample_Indi, OUTC = sample_Outc, THER = sample_Ther,
  DRUG_SUPP = sample_Drug_Supp
)
for (name in names(fake_tables)) {
  saveRDS(fake_tables[[name]], file.path(fake_root, "data", "99Q1", paste0(name, ".rds")))
}

test_that("import() returns the table and assigns it where it is called", {
  local_mocked_bindings(diana_root = function() fake_root)
  res <- import("DRUG", quarter = "99Q1")
  expect_equal(nrow(res), nrow(sample_Drug))
  expect_true(exists("Drug", inherits = FALSE))
})

test_that("import() inside a function does not touch the global environment", {
  local_mocked_bindings(diana_root = function() fake_root)
  had_drug <- exists("Drug", envir = globalenv(), inherits = FALSE)
  f <- function() {
    import("DRUG", quarter = "99Q1")
    exists("Drug", inherits = FALSE)
  }
  expect_true(f())
  expect_equal(exists("Drug", envir = globalenv(), inherits = FALSE), had_drug)
})

test_that("import() can subset by pids and skip the assignment", {
  local_mocked_bindings(diana_root = function() fake_root)
  pids <- unique(sample_Drug$primaryid)[1:10]
  res <- import("DRUG", quarter = "99Q1", pids = pids, save_in_environment = FALSE)
  expect_setequal(unique(res$primaryid), pids)
  expect_false(exists("Drug", inherits = FALSE))
})

test_that("import() explains a missing dataset", {
  local_mocked_bindings(diana_root = function() fake_root)
  expect_error(import("DRUG", quarter = "98Q1"), "does not exist.*setup_DiAna\\(\"98Q1\"\\)")
})

test_that("import() explains a missing FAERS_version", {
  local_mocked_bindings(diana_root = function() fake_root)
  skip_if(exists("FAERS_version"))
  expect_error(import("DRUG"), "`quarter` was not supplied.*FAERS_version")
})

test_that("retrieve_pregnancy_pids() uses its quarter argument and leaves the workspace alone", {
  local_mocked_bindings(diana_root = function() fake_root)
  before <- ls(globalenv())
  expect_equal(
    suppressWarnings(retrieve_pregnancy_pids(quarter = "99Q1"), classes = "deprecatedWarning")[1:4],
    suppressWarnings(retrieve_pregnancy_pids(quarter = "sample"), classes = "deprecatedWarning")[1:4]
  )
  expect_equal(ls(globalenv()), before)
})

# dictionaries in the fake project
dir.create(file.path(fake_root, "external_sources"), showWarnings = FALSE)
fake_meddra_file <- data.frame(
  def = 1, soc = "soc a", hlgt = "hlgt a", hlt = c("hlt a", "hlt a", "hlt b"),
  pt = c("nausea", "nausea", "vomiting")
)
write.table(fake_meddra_file, file.path(fake_root, "external_sources", "meddra_primary.csv"), sep = ";", row.names = FALSE)
fake_atc_file <- data.frame(
  Substance = c("paracetamol", "paracetamol"), code = c("N02BE01", "X"), primary_code = "N02BE01",
  Lvl4 = "N02BE", Class4 = "anilides", Lvl3 = "N02B", Class3 = "other analgesics",
  Lvl2 = "N02", Class2 = "analgesics", Lvl1 = "N", Class1 = "nervous system"
)
write.table(fake_atc_file, file.path(fake_root, "external_sources", "ATC_DiAna.csv"), sep = ";", row.names = FALSE)

test_that("import_MedDRA() reads the dictionary, removes duplicates and assigns it where called", {
  local_mocked_bindings(diana_root = function() fake_root)
  res <- import_MedDRA()
  expect_named(res, c("def", "soc", "hlgt", "hlt", "pt"))
  expect_equal(nrow(res), 2)
  expect_true(exists("MedDRA", inherits = FALSE))
})

test_that("import_ATC() keeps only primary codes unless asked otherwise", {
  local_mocked_bindings(diana_root = function() fake_root)
  expect_equal(nrow(import_ATC()), 1)
  expect_true(exists("ATC", inherits = FALSE))
  expect_equal(nrow(import_ATC(primary = FALSE, env = environment())), 2)
  expect_named(import_ATC(), c("substance", "code", "primary_code", "Lvl4", "Class4", "Lvl3", "Class3", "Lvl2", "Class2", "Lvl1", "Class1"))
})

test_that("import_MedDRA() and import_ATC() explain a missing file", {
  empty_root <- tempfile("diana_")
  dir.create(empty_root)
  local_mocked_bindings(diana_root = function() empty_root)
  expect_error(import_MedDRA(), "MedDRA is not available")
  expect_error(import_ATC(), "ATC cannot be found")
})

test_that("new_descriptive() imports the tables of a quarter", {
  local_mocked_bindings(diana_root = function() fake_root)
  pids <- unique(sample_Drug[substance == "adalimumab"]$primaryid)
  from_quarter <- suppressWarnings(new_descriptive(pids, drug = "adalimumab", database = "99Q1"))
  from_sample <- suppressWarnings(new_descriptive(pids, drug = "adalimumab", database = "sample"))
  expect_equal(from_quarter, from_sample)
})

test_that("new_descriptive(database = 'VigiBase') leaves out continents", {
  vigibase_root <- tempfile("diana_")
  dir.create(file.path(vigibase_root, "data"), recursive = TRUE)
  file.copy(file.path(fake_root, "data", "99Q1"), file.path(vigibase_root, "data"), recursive = TRUE)
  file.rename(file.path(vigibase_root, "data", "99Q1"), file.path(vigibase_root, "data", "VigiBase"))
  local_mocked_bindings(diana_root = function() vigibase_root)
  pids <- unique(sample_Drug[substance == "adalimumab"]$primaryid)
  res <- suppressWarnings(new_descriptive(pids, database = "VigiBase"))
  expect_false("__continent__" %in% res[[1]] || "continent" %in% res[[1]])
  expect_true(any(res[[1]] %in% c("country", "__country__")))
})

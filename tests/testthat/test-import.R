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
    retrieve_pregnancy_pids(quarter = "99Q1")[1:4],
    retrieve_pregnancy_pids(quarter = "sample")[1:4]
  )
  expect_equal(ls(globalenv()), before)
})

smq_root <- tempfile("diana_")
dir.create(file.path(smq_root, "external_sources"), recursive = TRUE)
smq_file <- file.path(smq_root, "external_sources", "smq_dictionary.csv")

write_smq <- function(x) write.table(x, smq_file, sep = ";", row.names = FALSE, na = "")
smq <- data.frame(
  SMQ_1 = c("hepatic disorders", "hepatic disorders", "hepatic disorders", "lactic acidosis"),
  SMQ_2 = c("drug related hepatic disorders", "drug related hepatic disorders", "liver infections", NA),
  SMQ_3 = NA, SMQ_4 = NA, SMQ_5 = NA,
  pt = c("hepatitis", "jaundice", "hepatitis a", "acidosis"),
  NB = c("Narrow", "Broad", "Narrow", "Broad")
)

test_that("extractSMQ() lists every SMQ once, with its terms, and no empty levels", {
  local_mocked_bindings(diana_root = function() smq_root)
  write_smq(smq)
  all_terms <- extractSMQ(Narrow = FALSE)
  expect_named(all_terms, c("hepatic disorders", "lactic acidosis", "drug related hepatic disorders", "liver infections"))
  expect_equal(all_terms[["drug related hepatic disorders"]], c("hepatitis", "jaundice"))
  narrow <- extractSMQ(Narrow = TRUE)
  expect_equal(narrow[["hepatic disorders"]], c("hepatitis", "hepatitis a"))
  # an SMQ with only broad terms stays listed, empty
  expect_true("lactic acidosis" %in% names(narrow))
  expect_length(narrow[["lactic acidosis"]], 0)
})

test_that("extractSMQ() explains a missing or malformed dictionary", {
  local_mocked_bindings(diana_root = function() smq_root)
  unlink(smq_file)
  expect_error(extractSMQ(), "SMQ dictionary was not found.*SMQ_1 to SMQ_5, pt and NB")
  write_smq(smq[, names(smq) != "NB"])
  expect_error(extractSMQ(), "missing column\\(s\\): NB")
})

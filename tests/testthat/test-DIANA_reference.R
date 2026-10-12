test_that("FAERS specifics works", {
  expect_no_error(FAERS_quarter_specifics("23Q1", print = FALSE))
})

test_that("FAERS_quarter_specifics() reports the MedDRA version of each quarter", {
  expect_match(FAERS_quarter_specifics("24Q1", print = FALSE)[4], "version 26\\.1\\)$")
  expect_match(FAERS_quarter_specifics("25Q4", print = FALSE)[4], "version 29\\.0\\)$")
  for (q in names(meddra_versions)) {
    expect_match(FAERS_quarter_specifics(q, print = FALSE), paste0("version ", meddra_versions[[q]]), all = FALSE)
  }
  expect_match(FAERS_quarter_specifics("23Q1", print = FALSE)[3], "No information concerning the MedDRA version")
  expect_match(FAERS_quarter_specifics("23Q1", print = FALSE)[1], "is 23Q1$")
})

test_that("print = TRUE prints the text and returns it invisibly; print = FALSE only returns it", {
  expect_output(res <- withVisible(FAERS_quarter_specifics("24Q2")), "version 27\\.0")
  expect_false(res$visible)
  expect_silent(res <- withVisible(FAERS_quarter_specifics("24Q2", print = FALSE)))
  expect_true(res$visible)
  expect_equal(res$value, FAERS_quarter_specifics("24Q2", print = FALSE))

  expect_output(ref <- DiAna_reference(), "To cite this package")
  expect_match(ref, "DiAna version", all = FALSE)
  expect_silent(DiAna_reference(print = FALSE))
})

test_that("An unavailable quarter fails before asking or creating folders", {
  asked <- FALSE
  local_mocked_bindings(ask_yes_no = function(msg) {
    asked <<- TRUE
    FALSE
  })
  expect_error(setup_DiAna("22Q9"), "Available quarters: 23Q1")
  # folders are created only after the question, so no question means no folders
  expect_false(asked)
})

test_that("Answering no, or cancelling the dialog, downloads nothing", {
  local_mocked_bindings(ask_yes_no = function(msg) FALSE)
  expect_null(setup_DiAna("25Q4"))
  local_mocked_bindings(ask_yes_no = function(msg) NA)
  expect_null(setup_DiAna("25Q4"))
})

test_that("Every available quarter has its own OSF download link", {
  expect_true(all(grepl("^https://osf\\.io/download/[a-z0-9]+/$", DiAna_quarter_urls)))
  expect_false(anyDuplicated(DiAna_quarter_urls) > 0)
})

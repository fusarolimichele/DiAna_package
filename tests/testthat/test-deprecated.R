test_that("hierarchycal_rates() warns and passes its arguments to hierarchical_rates()", {
  local_mocked_bindings(hierarchical_rates = function(...) list(...))
  expect_warning(
    res <- hierarchycal_rates(1:3, entity = "indication", file_name = "x.xlsx"),
    "hierarchical_rates",
    class = "deprecatedWarning"
  )
  expect_equal(res, list(1:3, entity = "indication", file_name = "x.xlsx"))
})

test_that("hierarchycal_rates() keeps file_name missing when it is not given", {
  # hierarchical_rates() writes a file only if file_name is supplied, so the
  # wrapper must not turn a missing file_name into a supplied one
  local_mocked_bindings(hierarchical_rates = function(pids_cases, entity, file_name) missing(file_name))
  expect_true(suppressWarnings(hierarchycal_rates(1:3, entity = "reaction")))
})

test_that("retrieve_pregnancy_pids() is deprecated and points to PVgravID", {
  expect_warning(
    retrieve_pregnancy_pids(quarter = "sample"),
    "PVgravID",
    class = "deprecatedWarning"
  )
})

test_that("Pregnancy algorithm manages to retrieve inherent pids", {
  expect_equal(
    suppressWarnings(retrieve_pregnancy_pids(quarter = "sample"), classes = "deprecatedWarning")[1:4],
    list(
      high_specificity = c(
        209984413, 90142505, 122688521, 141551261,
        172405551, 186233281, 196446181, 214536961
      ),
      medium_specificity = c(
        209984413, 90142505, 122688521, 141551261,
        172405551, 186233281, 196446181, 214536961,
        164548722
      ),
      low_specificity = c(
        164548722, 196446181, 209984413, 4756942,
        5925427, 5979454, 8394745, 90142505, 106956872,
        122688521, 123161621, 141551261, 172405551,
        181456962, 186233281, 188741961, 214536961
      ),
      paternal_exposure = 188741961
    )
  )
})

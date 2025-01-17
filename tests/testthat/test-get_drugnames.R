test_that("Get_drugnames works", {
  expect_equal(
    as.character(get_drugnames("adalimumab", sample_Drug, sample_Drug_Name)$drugname),
    c("humira", "imraldi", "adalimumab")
  )
})

test_that("Network analysis works on reactions", {
  expect_equal(E(network_analysis(pids = sample_Demo[sex=="F"]$primaryid,
                                       entity = "reaction",temp_reac=sample_Reac,
                                       temp_indi=sample_Indi,temp_drug=sample_Drug,
                                       save_plot = FALSE))$weight,c(3.059249192466, 2.60242767931506, 2.95203709347611, 3.74642190009261,
                                                                    3.7334279338972))
})

test_that("Network analysis works on indications", {
  expect_equal(E(network_analysis(pids = sample_Demo[sex=="F"]$primaryid,
                                  entity = "indication",temp_reac=sample_Reac,
                                  temp_indi=sample_Indi,temp_drug=sample_Drug,
                                  save_plot = FALSE))$weight,2.31324677223405)
})

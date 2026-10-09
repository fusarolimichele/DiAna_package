test_that("Network analysis works on reactions", {
  expect_equal(E(network_analysis(
    pids = sample_Demo[sex == "F"]$primaryid,
    entity = "reaction", temp_reac = sample_Reac,
    temp_indi = sample_Indi, temp_drug = sample_Drug,
    save_plot = FALSE
  ))$weight, c(2.52108598380101, 3.96094742934548))
})

test_that("Network analysis works on indications", {
  expect_equal(E(network_analysis(
    pids = sample_Demo[sex == "F"]$primaryid,
    entity = "indication", temp_reac = sample_Reac,
    temp_indi = sample_Indi, temp_drug = sample_Drug,
    save_plot = FALSE
  ))$weight, 2.80527125282867)
})

test_that("Network analysis drops rare and near-universal terms (min_frequency_term)", {
  pids <- sample_Demo[sex == "F"]$primaryid
  df <- unique(sample_Reac[primaryid %in% pids, .(primaryid, pt)])
  n_pids <- length(unique(df$primaryid))
  counts <- df[, .N, by = "pt"]
  kept_terms <- counts[N > n_pids * 0.01 & N < n_pids - 1]$pt

  g <- network_analysis(
    pids = pids, entity = "reaction", temp_reac = sample_Reac,
    remove_singlet = FALSE, save_plot = FALSE
  )
  expect_setequal(V(g)$name, kept_terms)
  expect_lt(length(V(g)), nrow(counts))
})

test_that("Network analysis works on suspected substances and saves the plot when asked", {
  file <- tempfile(fileext = ".tiff")
  g <- network_analysis(
    pids = sample_Demo$primaryid, entity = "substance", restriction = "suspects",
    temp_drug = sample_Drug, file_name = file
  )
  expect_s3_class(g, "igraph")
  expect_true(file.exists(file))
  expect_gt(file.size(file), 0)
})

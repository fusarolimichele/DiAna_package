test_that("Time to onset analysis works", {
  expect_equal(time_to_onset_analysis("skin care", "acne",
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther
  )$Q2, 13)
  expect_equal(time_to_onset_analysis("skin care",
    list("skin affection" = list("erythema", "skin irritation", "dry skin")),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1
  )$Q1, 8)
})

test_that("Time to onset analysis accepts complex queries", {
  expect_equal(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin"), "acne" = "acne"),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1
  )$Q2, list(15, 13))
})

test_that("Time to onset analysis works when the restriction parameter is specified", {
  expect_equal(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin"), "acne" = "acne"),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1,
    restriction = sample_Demo[sex == "F"]$primaryid
  )$Q2, list(13, 15))
})

test_that("Time to onset analysis works when using the KS test", {
  expect_equal(suppressWarnings(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin"), "acne" = "acne"),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1, test = "KS",
    restriction = sample_Demo[sex == "F"]$primaryid
  )$Q2), list(13, 15))
})

test_that("Time to onset analysis works when changing the max tto", {
  expect_equal(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin"), "acne" = "acne"),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1, max_TTO = 20,
    restriction = sample_Demo[sex == "F"]$primaryid
  )$Q2, list(15, 13))
})


test_that("Plot KS works", {
  expect_snapshot(t <- plot_KS(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin")),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1, max_TTO = 20,
    restriction = sample_Demo[sex == "F"]$primaryid
  )))
})

test_that("Render TTO works", {
  expect_snapshot(t <- render_tto(time_to_onset_analysis(list("potential anti-acneic" = list("skin care", "adapalene")),
    list("skin irritated" = list("erythema", "skin irritation", "dry skin")),
    temp_drug = sample_Drug, temp_reac = sample_Reac,
    temp_ther = sample_Ther, minimum_cases = 1,
    restriction = sample_Demo[sex == "F"]$primaryid
  )))
})

test_that("render_tto() nested and faceted plots build without errors", {
  pdf(NULL)
  on.exit(dev.off(), add = TRUE)
  tto <- time_to_onset_analysis(list("skin care", "adapalene"),
    list("erythema", "dry skin", "skin irritation"),
    temp_drug = sample_Drug, temp_reac = sample_Reac, temp_ther = sample_Ther
  )
  tto2 <- rbind(data.table::copy(tto)[, analysis := "a"], data.table::copy(tto)[, analysis := "b"])
  plots <- list(
    render_tto(tto2, nested = "analysis"),
    render_tto(tto2, nested = "analysis", nested_colors = c("black", "red"), facet_h = "event"),
    render_tto(tto, facet_v = "event")
  )
  for (p in plots) {
    expect_s3_class(p, "ggplot")
    expect_no_error(ggplot2::ggplot_build(p))
  }
})

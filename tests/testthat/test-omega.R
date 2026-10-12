test_that("omega works starting from input combination and DiAna data model", {
  skip_if_not_installed("pvOmega")
  expect_equal(
    omega_analysis(
      drug1_selected = "paracetamol",
      drug2_selected = "ibuprofen",
      reac_selected = "overdose",
      temp_drug = DiAna::sample_Drug,
      temp_reac = DiAna::sample_Reac
    ),
    data.table::data.table(
      drug1 = "paracetamol", drug2 = "ibuprofen", event = "overdose",
      n1.1 = 5, n.11 = 0, n1.. = 51, n.1. = 15, n..1 = 15, n... = 1000,
      n111 = 0, n110 = 6, n101 = 5, n100 = 40, n011 = 0, n010 = 9,
      n001 = 10, n000 = 930, n11. = 6, n10. = 45, n01. = 9, n00. = 940,
      f00 = 0.0106382978723404, f10 = 0.111111111111111, f01 = 0,
      f11 = 0, g11 = 0.111111111111111, E111 = 0.666666666666667,
      omega = -1.22239242133645, omega_lower = -11.2142802371433,
      omega_upper = 1.10641135999973, label_omega = "-1.22 (-11.21; 1.11) [0]",
      omega_signal = structure(1L, levels = c(
        "not enough cases",
        "no SDR", "SDR"
      ), class = c("ordered", "factor"))
    )
  )
})

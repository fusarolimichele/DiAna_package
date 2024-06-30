test_that("Basic disproportionality on numbers work", {
  t <- disproportionality_comparison(100, 50, 3, 20000, print_results = FALSE)
  expect_equal(t$ROR, "13.05 (2.55-41.71)")
  expect_equal(t$PRR, "12.7 (4.02-40.14)")
  expect_equal(t$RRR, "12 (3.81-37.84)")
  expect_equal(t$IC, "2.22 (0.15-3.42)")
  expect_equal(t$IC_gamma, "0.53 (0.17-3.42)")
})

test_that("Errors in input to disproportionality comparison are correctly identified", {
  expect_error(disproportionality_comparison(100, 50, 1000, 20000), "The count of reports recording a drug cannot be lower than the count of reports recording the drug and the event. Please check the provided counts.")
  expect_error(disproportionality_comparison(10000, 50, 1000, 20000), "The count of reports recording an event cannot be lower than the count of reports recording the drug and the event. Please check the provided counts.")
  expect_error(disproportionality_comparison(100000, 50, 10, 20000), "The count of total reports cannot be lower than any other provided count. Please check the provided counts.")
})

test_that("Disproportionality on databases works on lists", {
  expect_equal(disproportionality_analysis("paracetamol", "nausea", sample_Drug, sample_Reac)$label_ROR, "1.57 (0.17-6.64) [2]")
  expect_equal(disproportionality_analysis(list("paracetamol", "infliximab"), "nausea", sample_Drug, sample_Reac)$label_ROR, c("1.57 (0.17-6.64) [2]", "0 (0-12.88) [0]"))
  expect_equal(disproportionality_analysis(list("paracetamol", "infliximab"), list("nausea", "injection site pain"), sample_Drug, sample_Reac)$label_ROR, c("1.57 (0.17-6.64) [2]", "0 (0-12.88) [0]", "0 (0-7.55) [0]", "0 (0-33.65) [0]"))
})
test_that("Disproportionality on databases works on lists of lists", {
  expect_equal(disproportionality_analysis(list("TNF-alpha inhibitors" = list("infliximab", "etanercept", "adalimumab")), list("nausea", "injection site pain"), sample_Drug, sample_Reac)$label_ROR, c("1.32 (0.25-4.53) [3]", "12.85 (3.19-54.52) [6]"))
  expect_equal(disproportionality_analysis(list("infliximab", "etanercept", "adalimumab"), list("malaise" = list("nausea", "vomiting", "abdominal discomfort", "malaise")), sample_Drug, sample_Reac)$label_ROR, c("2.8 (0.29-13.29) [2]", "1.96 (0.58-5.26) [5]", "1.31 (0.25-4.35) [3]"))
  expect_equal(disproportionality_analysis(list("TNF-alpha inhibitors" = list("infliximab", "etanercept", "adalimumab")), list("malaise" = list("nausea", "vomiting", "abdominal discomfort", "malaise")), sample_Drug, sample_Reac)$label_ROR, c("1.54 (0.61-3.41) [8]"))
})

test_that("Disproportionality on databases works with heterogeneous input in drug (and reac) selected", {
  t1 <- disproportionality_analysis(list("TNF-alpha inhibitors" = list("adalimumab", "etanercept", "infliximab"), "analgesics" = list("morphine", "paracetamol")), list("nausea", "injection site pain"), sample_Drug, sample_Reac)
  t2 <- disproportionality_analysis(list("adalimumab", "etanercept", "infliximab"), list("nausea", "injection site pain"), sample_Drug, sample_Reac)
  expect_equal(
    disproportionality_analysis(drug_selected = c("TNF-alpha inhibitors" = list("adalimumab", "etanercept", "infliximab"), "analgesics" = list("morphine", "paracetamol")), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t1
  )
  expect_equal(
    disproportionality_analysis(drug_selected = c("TNF-alpha inhibitors" = list("adalimumab", "etanercept", "infliximab"), "analgesics" = c("morphine", "paracetamol")), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t1
  )
  expect_equal(
    disproportionality_analysis(drug_selected = c("TNF-alpha inhibitors" = c("adalimumab", "etanercept", "infliximab"), "analgesics" = list("morphine", "paracetamol")), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t1
  )
  expect_equal(
    disproportionality_analysis(drug_selected = c("TNF-alpha inhibitors" = list("adalimumab", "etanercept", "infliximab"), "analgesics" = c("morphine", "paracetamol")), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t1
  )
  expect_equal(
    disproportionality_analysis(drug_selected = list("TNF-alpha inhibitors" = c("adalimumab", "etanercept", "infliximab"), "analgesics" = c("morphine", "paracetamol")), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t1
  )
  expect_equal(
    disproportionality_analysis(drug_selected = c("adalimumab", "etanercept", "infliximab"), reac_selected = list("nausea", "injection site pain"), temp_d = sample_Drug, temp_r = sample_Reac),
    t2
  )
})


test_that("Disproportionality trend works", {
  expect_equal(
    disproportionality_trend("adalimumab", "injection site pain", temp_d = sample_Drug, temp_r = sample_Reac, temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp)$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-947.76) [0]",
      "0 (0-149.64) [0]", "0 (0-118.19) [0]", "0 (0-44.09) [0]", "0 (0-48.97) [0]",
      "6 (0.11-78.19) [1]", "3.09 (0.06-27.04) [1]", "2.77 (0.05-22.81) [1]",
      "5.18 (0.51-27.55) [2]", "5.13 (0.51-27.05) [2]", "5.58 (0.55-29.38) [2]",
      "5.52 (0.55-28.9) [2]", "4.87 (0.49-24.57) [2]"
    )
  )
})

test_that("Disproportionality trend works with customized queries", {
  expect_equal(
    disproportionality_trend(list("adalimumab", "etanercept", "infliximab"), "injection site pain",
      temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp
    )$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (0.22-Inf) [1]",
      "Inf (1.56-Inf) [2]", "Inf (1.32-Inf) [2]", "Inf (2.89-Inf) [3]",
      "Inf (3.05-Inf) [3]", "Inf (4.85-Inf) [4]", "9.93 (1.63-69.42) [4]",
      "13.44 (2.54-88.52) [5]", "13.32 (3.07-65.91) [6]", "13.97 (3.23-68.78) [6]",
      "15.52 (3.59-76.43) [6]", "15.99 (3.7-78.62) [6]", "12.85 (3.19-54.52) [6]"
    )
  )
  expect_equal(
    disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
      list("injection site pain", "injection site reaction", "injection site discomfort"),
      temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp
    )$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (1.09-Inf) [2]", "Inf (1.27-Inf) [2]",
      "Inf (1.51-Inf) [2]", "Inf (1.6-Inf) [2]", "Inf (1.9-Inf) [2]",
      "Inf (3.86-Inf) [3]", "Inf (5.95-Inf) [4]", "Inf (4.89-Inf) [4]",
      "Inf (8.86-Inf) [6]", "Inf (9.24-Inf) [6]", "Inf (11.16-Inf) [7]",
      "18.25 (4.03-112.71) [7]", "22.5 (5.23-135.58) [8]", "20.87 (5.63-95.41) [9]",
      "21.8 (5.9-99.4) [9]", "19.33 (5.65-75.46) [9]", "19.87 (5.82-77.35) [9]",
      "16.62 (5.13-58.28) [9]"
    )
  )
})

test_that("Disproportionality trend works also in a incidental way", {
  expect_equal(
    disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
      list("injection site pain", "injection site reaction", "injection site discomfort"),
      temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      cumulative = FALSE
    )$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (0.6-Inf) [2]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (0.16-Inf) [1]",
      "Inf (0.16-Inf) [1]", "0 (0-Inf) [0]", "Inf (1.24-Inf) [2]",
      "0 (0-Inf) [0]", "Inf (0.16-Inf) [1]", "0 (0-18.33) [0]", "Inf (0.33-Inf) [1]",
      "23.23 (0.25-2069.09) [1]", "0 (0-Inf) [0]", "0 (0-1386.32) [0]",
      "0 (0-Inf) [0]", "0 (0-579.71) [0]"
    )
  )
})

test_that("Disproportionality trend works also using quarters and months", {
  expect_equal(
    disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
      list("injection site pain", "injection site reaction", "injection site discomfort"),
      temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "quarter"
    )$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (1.95-Inf) [2]", "Inf (2.16-Inf) [2]",
      "Inf (2.2-Inf) [2]", "Inf (2.42-Inf) [2]", "Inf (2.03-Inf) [2]",
      "Inf (2.14-Inf) [2]", "Inf (2.28-Inf) [2]", "Inf (2.04-Inf) [2]",
      "Inf (2.24-Inf) [2]", "Inf (2.3-Inf) [2]", "Inf (2.54-Inf) [2]",
      "Inf (2.37-Inf) [2]", "Inf (2.22-Inf) [2]", "Inf (2.08-Inf) [2]",
      "Inf (2.16-Inf) [2]", "Inf (2.36-Inf) [2]", "Inf (2.5-Inf) [2]",
      "Inf (2.37-Inf) [2]", "Inf (2.44-Inf) [2]", "Inf (2.59-Inf) [2]",
      "Inf (4.81-Inf) [3]", "Inf (7.42-Inf) [4]", "Inf (7.77-Inf) [4]",
      "Inf (7.08-Inf) [4]", "Inf (7.4-Inf) [4]", "Inf (6.48-Inf) [4]",
      "Inf (6.46-Inf) [4]", "Inf (5.81-Inf) [4]", "Inf (5.51-Inf) [4]",
      "Inf (6.88-Inf) [5]", "Inf (6.89-Inf) [5]", "Inf (7.16-Inf) [5]",
      "Inf (9.58-Inf) [6]", "Inf (9.22-Inf) [6]", "Inf (9.35-Inf) [6]",
      "Inf (10.04-Inf) [6]", "Inf (9.98-Inf) [6]", "Inf (12.07-Inf) [7]",
      "Inf (12.48-Inf) [7]", "Inf (12.21-Inf) [7]", "Inf (11.82-Inf) [7]",
      "59.74 (7.44-2702.53) [7]", "59.59 (7.43-2694.08) [7]", "62.02 (7.73-2801.34) [7]",
      "28.73 (5.3-288.07) [7]", "19.05 (4.21-117.59) [7]", "19.46 (4.3-120.15) [7]",
      "20.58 (4.55-126.23) [7]", "23.81 (5.53-143.27) [8]", "27.36 (6.6-161.41) [9]",
      "21.37 (5.76-97.81) [9]", "22.02 (5.94-100.77) [9]", "22.17 (5.98-101.39) [9]",
      "21.95 (5.93-100.26) [9]", "22.32 (6.03-101.91) [9]", "22.64 (6.12-103.37) [9]",
      "22.55 (6.1-102.8) [9]", "22.91 (6.21-104.44) [9]", "23.69 (6.42-107.98) [9]",
      "24.42 (6.62-111.31) [9]", "19.95 (5.83-77.77) [9]", "20.04 (5.86-78.09) [9]",
      "20.2 (5.9-78.68) [9]", "20.61 (6.03-80.19) [9]", "20.52 (6.01-79.82) [9]",
      "17.21 (5.32-60.34) [9]"
    )
  )
  expect_equal(
    disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
      list("injection site pain", "injection site reaction", "injection site discomfort"),
      temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "month"
    )$label_ROR,
    c(
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]", "0 (0-Inf) [0]",
      "0 (0-Inf) [0]", "0 (0-Inf) [0]", "Inf (1.09-Inf) [2]", "Inf (1.16-Inf) [2]",
      "Inf (1.23-Inf) [2]", "Inf (1.27-Inf) [2]", "Inf (1.3-Inf) [2]",
      "Inf (1.44-Inf) [2]", "Inf (1.24-Inf) [2]", "Inf (1.27-Inf) [2]",
      "Inf (1.3-Inf) [2]", "Inf (1.33-Inf) [2]", "Inf (1.36-Inf) [2]",
      "Inf (1.39-Inf) [2]", "Inf (1.42-Inf) [2]", "Inf (1.48-Inf) [2]",
      "Inf (1.54-Inf) [2]", "Inf (1.6-Inf) [2]", "Inf (1.38-Inf) [2]",
      "Inf (1.41-Inf) [2]", "Inf (1.46-Inf) [2]", "Inf (1.51-Inf) [2]",
      "Inf (1.53-Inf) [2]", "Inf (1.56-Inf) [2]", "Inf (1.66-Inf) [2]",
      "Inf (1.68-Inf) [2]", "Inf (1.71-Inf) [2]", "Inf (1.74-Inf) [2]",
      "Inf (1.84-Inf) [2]", "Inf (1.66-Inf) [2]", "Inf (1.75-Inf) [2]",
      "Inf (1.6-Inf) [2]", "Inf (1.66-Inf) [2]", "Inf (1.54-Inf) [2]",
      "Inf (1.56-Inf) [2]", "Inf (1.61-Inf) [2]", "Inf (1.7-Inf) [2]",
      "Inf (1.72-Inf) [2]", "Inf (1.79-Inf) [2]", "Inf (1.83-Inf) [2]",
      "Inf (1.85-Inf) [2]", "Inf (1.9-Inf) [2]", "Inf (1.78-Inf) [2]",
      "Inf (1.8-Inf) [2]", "Inf (1.82-Inf) [2]", "Inf (1.85-Inf) [2]",
      "Inf (1.88-Inf) [2]", "Inf (1.9-Inf) [2]", "Inf (1.91-Inf) [2]",
      "Inf (2-Inf) [2]", "Inf (4.01-Inf) [3]", "Inf (3.61-Inf) [3]",
      "Inf (3.86-Inf) [3]", "Inf (3.72-Inf) [3]", "Inf (5.95-Inf) [4]",
      "Inf (6.08-Inf) [4]", "Inf (6.24-Inf) [4]", "Inf (6.32-Inf) [4]",
      "Inf (6.41-Inf) [4]", "Inf (6.11-Inf) [4]", "Inf (5.95-Inf) [4]",
      "Inf (6.02-Inf) [4]", "Inf (5.74-Inf) [4]", "Inf (5.88-Inf) [4]",
      "Inf (5.95-Inf) [4]", "Inf (5.85-Inf) [4]", "Inf (5.49-Inf) [4]",
      "Inf (5.37-Inf) [4]", "Inf (5.51-Inf) [4]", "Inf (5.39-Inf) [4]",
      "Inf (5.42-Inf) [4]", "Inf (5.53-Inf) [4]", "Inf (5.12-Inf) [4]",
      "Inf (4.92-Inf) [4]", "Inf (4.82-Inf) [4]", "Inf (4.87-Inf) [4]",
      "Inf (4.98-Inf) [4]", "Inf (5.07-Inf) [4]", "Inf (6.32-Inf) [5]",
      "Inf (6.41-Inf) [5]", "Inf (6.52-Inf) [5]", "Inf (6.41-Inf) [5]",
      "Inf (6.51-Inf) [5]", "Inf (6.59-Inf) [5]", "Inf (6.67-Inf) [5]",
      "Inf (6.76-Inf) [5]", "Inf (8.69-Inf) [6]", "Inf (8.83-Inf) [6]",
      "Inf (8.93-Inf) [6]", "Inf (8.88-Inf) [6]", "Inf (8.56-Inf) [6]",
      "Inf (8.52-Inf) [6]", "Inf (8.45-Inf) [6]", "Inf (8.57-Inf) [6]",
      "Inf (8.63-Inf) [6]", "Inf (8.9-Inf) [6]", "Inf (9.2-Inf) [6]",
      "Inf (9.38-Inf) [6]", "Inf (9.41-Inf) [6]", "Inf (9.53-Inf) [6]",
      "Inf (9.24-Inf) [6]", "Inf (8.92-Inf) [6]", "Inf (11.1-Inf) [7]",
      "Inf (11.27-Inf) [7]", "Inf (11.53-Inf) [7]", "Inf (11.66-Inf) [7]",
      "Inf (11.92-Inf) [7]", "Inf (11.99-Inf) [7]", "Inf (11.75-Inf) [7]",
      "Inf (11.5-Inf) [7]", "Inf (11.41-Inf) [7]", "Inf (11.27-Inf) [7]",
      "Inf (11.16-Inf) [7]", "Inf (11.02-Inf) [7]", "55.53 (6.91-2516.06) [7]",
      "56.09 (6.98-2540.96) [7]", "55.4 (6.9-2509.37) [7]", "28.63 (5.26-287.94) [7]",
      "28.34 (5.21-285) [7]", "28.62 (5.26-287.67) [7]", "28.47 (5.24-286.11) [7]",
      "28.93 (5.32-290.69) [7]", "18.87 (4.16-116.76) [7]", "18.37 (4.05-113.49) [7]",
      "18.25 (4.03-112.71) [7]", "17.8 (3.93-109.76) [7]", "17.95 (3.96-110.73) [7]",
      "18.11 (4-111.71) [7]", "18.38 (4.06-113.42) [7]", "18.43 (4.07-113.64) [7]",
      "18.66 (4.12-115.08) [7]", "18.96 (4.19-117.01) [7]", "19.31 (4.27-119.19) [7]",
      "19.45 (4.3-120.02) [7]", "22.12 (5.14-133.34) [8]", "22.29 (5.18-134.34) [8]",
      "22.5 (5.23-135.58) [8]", "22.8 (5.3-137.32) [8]", "25.66 (6.2-151.27) [9]",
      "26.09 (6.3-153.78) [9]", "19.9 (5.37-91.04) [9]", "20.29 (5.47-92.84) [9]",
      "20.43 (5.51-93.48) [9]", "20.43 (5.51-93.43) [9]", "20.67 (5.58-94.54) [9]",
      "20.74 (5.6-94.86) [9]", "20.56 (5.55-94) [9]", "20.7 (5.59-94.62) [9]",
      "20.87 (5.63-95.41) [9]", "20.93 (5.65-95.63) [9]", "20.79 (5.62-94.94) [9]",
      "20.68 (5.59-94.42) [9]", "20.61 (5.57-94.06) [9]", "21.03 (5.69-95.97) [9]",
      "20.89 (5.65-95.3) [9]", "21.24 (5.75-96.9) [9]", "21.43 (5.8-97.78) [9]",
      "21.56 (5.83-98.36) [9]", "21.88 (5.92-99.81) [9]", "22.17 (6-101.13) [9]",
      "21.8 (5.9-99.4) [9]", "21.69 (5.88-98.85) [9]", "22.09 (5.98-100.66) [9]",
      "22.24 (6.03-101.36) [9]", "22.51 (6.1-102.62) [9]", "22.54 (6.11-102.72) [9]",
      "22.94 (6.22-104.52) [9]", "23.27 (6.31-106.04) [9]", "23.51 (6.37-107.15) [9]",
      "23.61 (6.4-107.6) [9]", "23.88 (6.48-108.83) [9]", "19.21 (5.61-74.99) [9]",
      "19.33 (5.65-75.46) [9]", "19.19 (5.61-74.9) [9]", "19.28 (5.64-75.27) [9]",
      "19.47 (5.69-76.02) [9]", "19.31 (5.65-75.36) [9]", "19.52 (5.71-76.19) [9]",
      "19.76 (5.78-76.99) [9]", "19.97 (5.84-77.79) [9]", "19.92 (5.83-77.58) [9]",
      "20.01 (5.85-77.93) [9]", "20.19 (5.91-78.63) [9]", "19.83 (5.8-77.18) [9]",
      "19.87 (5.82-77.35) [9]", "16.4 (5.07-57.5) [9]", "16.51 (5.1-57.89) [9]",
      "16.62 (5.13-58.28) [9]"
    )
  )
})

test_that("Render forest works as usual",{
  expect_snapshot(t <- render_forest(disproportionality_analysis("paracetamol", "nausea", sample_Drug, sample_Reac)))
})

test_that("Plot disproportionality trend works as usual",{
  expect_snapshot(t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
                                                                         list("injection site pain", "injection site reaction", "injection site discomfort"),
                                                                         temp_drug = sample_Drug, temp_reac = sample_Reac,
                                                                         temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
                                                                         time_granularity = "quarter"
  )))
  expect_snapshot(t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
                                                                              list("injection site pain", "injection site reaction", "injection site discomfort"),
                                                                              temp_drug = sample_Drug, temp_reac = sample_Reac,
                                                                              temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
                                                                              time_granularity = "month"
  ), time_granularity = "month"))
  expect_snapshot(t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
                                                                              list("injection site pain", "injection site reaction", "injection site discomfort"),
                                                                              temp_drug = sample_Drug, temp_reac = sample_Reac,
                                                                              temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
                                                                              time_granularity = "quarter"
  ),metric = "ROR", time_granularity = "quarter"))
  expect_snapshot(t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab", "etanercept", "infliximab"),
                                                                              list("injection site pain", "injection site reaction", "injection site discomfort"),
                                                                              temp_drug = sample_Drug, temp_reac = sample_Reac,
                                                                              temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
                                                                              time_granularity = "month"
  ),metric = "ROR", time_granularity = "month"))
})


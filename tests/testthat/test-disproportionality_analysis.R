test_that("Basic disproportionality on numbers work", {
  t <- disproportionality_comparison(100,50,3,20000,print_results=FALSE)
  expect_equal(t$ROR,"13.05 (2.55-41.71)")
  expect_equal(t$PRR,"12.7 (4.02-40.14)")
  expect_equal(t$RRR,"12 (3.81-37.84)")
  expect_equal(t$IC,"2.22 (0.15-3.42)")
  expect_equal(t$IC_gamma,"0.53 (0.17-3.42)")
})

test_that("Errors in input to disproportionality comparison are correctly identified",{
  expect_error(disproportionality_comparison(100,50,1000,20000),"The count of reports recording a drug cannot be lower than the count of reports recording the drug and the event. Please check the provided counts.")
  expect_error(disproportionality_comparison(10000,50,1000,20000),"The count of reports recording an event cannot be lower than the count of reports recording the drug and the event. Please check the provided counts.")
  expect_error(disproportionality_comparison(100000,50,10,20000),"The count of total reports cannot be lower than any other provided count. Please check the provided counts.")
})

test_that("Disproportionality on databases works on lists", {
  expect_equal(disproportionality_analysis("paracetamol","nausea",sample_Drug,sample_Reac)$label_ROR,"1.57 (0.17-6.64) [2]")
  expect_equal(disproportionality_analysis(list("paracetamol","infliximab"),"nausea",sample_Drug,sample_Reac)$label_ROR,c("1.57 (0.17-6.64) [2]","0 (0-12.88) [0]"))
  expect_equal(disproportionality_analysis(list("paracetamol","infliximab"),list("nausea","injection site pain"),sample_Drug,sample_Reac)$label_ROR,c("1.57 (0.17-6.64) [2]", "0 (0-12.88) [0]", "0 (0-7.55) [0]", "0 (0-33.65) [0]"))
})
test_that("Disproportionality on databases works on lists of lists", {
  expect_equal(disproportionality_analysis(list("TNF-alpha inhibitors"=list("infliximab","etanercept","adalimumab")),list("nausea","injection site pain"),sample_Drug,sample_Reac)$label_ROR,c("1.32 (0.25-4.53) [3]","12.85 (3.19-54.52) [6]"))
  expect_equal(disproportionality_analysis(list("infliximab","etanercept","adalimumab"),list("malaise" = list("nausea","vomiting","abdominal discomfort","malaise")),sample_Drug,sample_Reac)$label_ROR,c("2.8 (0.29-13.29) [2]", "1.96 (0.58-5.26) [5]", "1.31 (0.25-4.35) [3]"))
  expect_equal(disproportionality_analysis(list("TNF-alpha inhibitors"=list("infliximab","etanercept","adalimumab")),list("malaise" = list("nausea","vomiting","abdominal discomfort","malaise")),sample_Drug,sample_Reac)$label_ROR,c("1.54 (0.61-3.41) [8]"))
})

test_that("Disproportionality on databases works with heterogeneous input in drug (and reac) selected", {
  expect_equal(disproportionality_analysis(drug_selected=c("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  expect_equal(disproportionality_analysis(drug_selected=c("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=c("morphine","paracetamol")),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  expect_equal(disproportionality_analysis(drug_selected=c("TNF-alpha inhibitors"=c("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  expect_equal(disproportionality_analysis(drug_selected=c("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=c("morphine","paracetamol")),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  expect_equal(disproportionality_analysis(drug_selected=list("TNF-alpha inhibitors"=c("adalimumab","etanercept","infliximab"),"analgesics"=c("morphine","paracetamol")),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("TNF-alpha inhibitors"=list("adalimumab","etanercept","infliximab"),"analgesics"=list("morphine","paracetamol")),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  expect_equal(disproportionality_analysis(drug_selected=c("adalimumab","etanercept","infliximab"),reac_selected=list("nausea","injection site pain"),temp_d=sample_Drug,temp_r=sample_Reac),
               disproportionality_analysis(list("adalimumab","etanercept","infliximab"),list("nausea","injection site pain"),sample_Drug,sample_Reac))
  })



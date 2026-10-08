# Sample datasets: sample_Demo, sample_Demo_Supp, sample_Doses, sample_Drug,
# sample_Drug_Name, sample_Drug_Supp, sample_Indi, sample_Outc, sample_Reac,
# sample_Ther
#
# How they were made: 1,000 primaryid were drawn at random from Demo of the
# DiAna data for quarter 23Q1, and all the records of those reports were kept
# in every table. The original script and random seed were not kept, so this
# script documents the procedure: run on 23Q1, it gives a sample with the same
# structure, but not the same 1,000 reports. Do not re-run it to update the
# package data unless a new sample is intended, as examples and tests use
# values from the current one.
#
# Requires the 23Q1 data downloaded with setup_DiAna("23Q1").

library(DiAna)

quarter <- "23Q1"
set.seed(2023) # not the seed of the current sample, which was not recorded

pids <- sample(import("DEMO", quarter = quarter, save_in_environment = FALSE)$primaryid, 1000)

tables <- c(
  sample_Demo = "DEMO", sample_Demo_Supp = "DEMO_SUPP", sample_Doses = "DOSES",
  sample_Drug = "DRUG", sample_Drug_Name = "DRUG_NAME", sample_Drug_Supp = "DRUG_SUPP",
  sample_Indi = "INDI", sample_Outc = "OUTC", sample_Reac = "REAC", sample_Ther = "THER"
)
for (name in names(tables)) {
  assign(name, import(tables[[name]], quarter = quarter, pids = pids, save_in_environment = FALSE))
}

usethis::use_data(
  sample_Demo, sample_Demo_Supp, sample_Doses, sample_Drug, sample_Drug_Name,
  sample_Drug_Supp, sample_Indi, sample_Outc, sample_Reac, sample_Ther,
  overwrite = TRUE
)

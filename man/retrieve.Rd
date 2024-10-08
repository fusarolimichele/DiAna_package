% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/retrieve_cases.R
\name{retrieve}
\alias{retrieve}
\title{Retrieve data for specific primaryids}
\usage{
retrieve(
  pids,
  file_name = "individual_cases",
  temp_reac = Reac,
  temp_drug = Drug,
  temp_demo = Demo,
  temp_demo_supp = Demo_supp,
  temp_outc = Outc,
  temp_ther = Ther,
  temp_doses = Doses,
  temp_drug_supp = Drug_supp,
  temp_indi = Indi,
  temp_drug_name = Drug_name,
  temp_meddra = NA,
  temp_atc = NA,
  save_in_excel = TRUE
)
}
\arguments{
\item{pids}{Primaryids of interest.}

\item{file_name}{The name of the output xlsx file (default is "individual cases").}

\item{temp_reac}{Reac dataset. Can be set to sample_Reac for testing}

\item{temp_drug}{Drug dataset. Can be set to sample_Drug for testing}

\item{temp_demo}{Demo dataset. Defaults to Demo. Can be se to sample_Demo for testing}

\item{temp_demo_supp}{the Demo_supp databases. Can be set to sample_Demo_Supp for testing}

\item{temp_outc}{Outc dataset. Can be set to sample_Outc for testing}

\item{temp_ther}{Ther dataset. Can be set to sample_Ther for testing}

\item{temp_doses}{the Doses databases. Can be set to sample_Doses for testing}

\item{temp_drug_supp}{the Drug_supp databases. Can be set to sample_Drug_Supp for testing}

\item{temp_indi}{Indi dataset. Can be set to sample_Indi for testing}

\item{temp_drug_name}{the Drug_name databases. Can be set to sample_Drug_Name for testing}

\item{temp_meddra}{the MedDRA dictionary, if available. Defaults to NA for subscription requirement.}

\item{temp_atc}{the ATC classification, if available. Defaults to NA for testing.}

\item{save_in_excel}{Whether to save the outcome in an excel. Defaults to TRUE}
}
\value{
Two xlsx files with individual cases information:
one general with a row per ICSR,
and one with drug information and multiple rows per ICSR.
}
\description{
This function retrieves data for a specific group of primaryids,
allowing for in-depth case-by-case evaluation and clinical reasoning.
If MedDRA is available PTs are clustered by HLGT.
}
\examples{
FAERS_version <- "24Q1"
pids <- sample_Demo[sex == "M"]$primaryid
if (file.exists("data/24Q1.csv")) {
  retrieve(pids, save_in_excel = FALSE)
}

}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_drugnames.R
\name{get_drugnames}
\alias{get_drugnames}
\title{Retrieve Drug Names from FAERS Database}
\usage{
get_drugnames(drug, temp_d = Drug, temp_d_name = Drug_name)
}
\arguments{
\item{drug}{Character string representing the drug substance for which drug names are to be retrieved.}

\item{temp_d}{Drug database. Can be set to sample_Drug for testing.}

\item{temp_d_name}{Drug_name database. Can be set to sample_Drug_Name for testing.}
}
\value{
A data table containing drug names and their corresponding occurrence percentages.
}
\description{
This function retrieves drug names and their occurrence percentages from the FDA Adverse Event Reporting System (FAERS) database for a specified drug substance.
}
\details{
The function imports data from the "DRUG" and "DRUG_NAME" tables in the specified quarter of the FAERS database. It calculates the total number of occurrences for each unique drug name and orders the results in descending order based on occurrence count. The resulting data table includes drug names and their occurrence percentages.
}
\examples{
\dontrun{
# This example needs that setup_DiAna has been run before, to download DiAna dictionary
if (file.exists("external_source/DiAna_dictionary.csv")) {
  FAERS_version <- "24Q1"
  result <- get_drugnames("aripiprazole")
  print(result)
}
}
}
\seealso{
\code{\link{import}}
}

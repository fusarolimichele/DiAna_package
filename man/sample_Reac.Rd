% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{sample_Reac}
\alias{sample_Reac}
\title{Sample dataset containing events (suspected adverse drug reactions) and related information.}
\format{
A data.table with 3 variables:
\describe{
\item{primaryid}{Unique identifier for the report (primary ID)}
\item{pt}{Preferred term describing the adverse reaction according to the Medical Dictionary for Regulatory Activities}
\item{drug_rec_act}{Drug rechallenged action (if the event recurred at the rechallenge, it is going to be shown here).}
}
}
\source{
https://github.com/fusarolimichele/DiAna
}
\usage{
sample_Reac
}
\description{
This dataset provides information on adverse drug reactions (ADRs).
Each report (primaryid) can record multiple events (and rows).
}
\details{
This dataset is a subset of the actual Reac data (that can be downloaded using setup_DiAna()),
providing a glimpse into the structure of the database and allowing tests and documentation.
}
\keyword{datasets}

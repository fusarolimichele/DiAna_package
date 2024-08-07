% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{sample_Ther}
\alias{sample_Ther}
\title{Sample Data on Therapy Details}
\format{
A data.table with 7 variables:
\describe{
\item{primaryid}{Unique identifier for each individual (\code{numeric}).}
\item{drug_seq}{Sequence number identifying the specific drug within the report (\code{integer}).}
\item{start_dt}{Date of first administration of the therapy (\code{numeric}), in YYYYMMDD format.}
\item{dur_in_days}{Duration of therapy in days (\code{numeric}).}
\item{end_dt}{Date of last administration of the therapy (\code{numeric}), in YYYYMMDD format.}
\item{time_to_onset}{Time to onset of related events in days (\code{numeric}). We only have a TTO per drug, independently of the event, since we only have an event date for each report. The TTO is calculated as the difference between the event date and the start date.}
\item{event_dt}{Date of occurrence of the events (one per report even if there are multiple events) (\code{integer}), in YYYYMMDD format.}
}
}
\source{
https://github.com/fusarolimichele/DiAna
}
\usage{
sample_Ther
}
\description{
A dataset containing details on therapeutic interventions, including drug therapy start and end dates,
duration in days, time to onset of events related to therapy, and event dates.
}
\details{
This subset dataset provides detailed information on therapeutic interventions,
It facilitates analysis of therapy durations, and onset times.
}
\keyword{datasets}

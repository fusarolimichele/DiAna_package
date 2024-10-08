% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/disproportionality_analysis.R
\name{disproportionality_comparison}
\alias{disproportionality_comparison}
\title{Disproportionality Analysis for Drug-Event Combinations}
\usage{
disproportionality_comparison(
  drug_count = length(pids_drug),
  event_count = length(pids_event),
  drug_event_count = length(intersect(pids_drug, pids_event)),
  tot = nrow(Demo),
  print_results = TRUE
)
}
\arguments{
\item{drug_count}{An integer representing the number of reports for the drug of interest. Default is the length of \code{pids_drug}.}

\item{event_count}{An integer representing the number of reports for the event of interest. Default is the length of \code{pids_event}.}

\item{drug_event_count}{An integer representing the number of reports for the drug-event combination. Default is the length of the intersection of \code{pids_drug} and \code{pids_event}.}

\item{tot}{An integer representing the total number of reports in the dataset. Default is the number of rows in the \code{Demo} table.}

\item{print_results}{A logical to control whether the results should also be printed, besides being stored in the results.}
}
\value{
This function prints a contingency table and several disproportionality metrics (which are also stored in a list):
\itemize{
\item \code{ROR}: Reporting Odds Ratio with confidence intervals.
\item \code{PRR}: Proportional Reporting Ratio with confidence intervals.
\item \code{RRR}: Relative Reporting Ratio with confidence intervals.
\item \code{IC}: Information Component with confidence intervals.
\item \code{IC_gamma}: Gamma distribution-based Information Component with confidence intervals.
}
}
\description{
This function performs a disproportionality analysis for drug-event combinations in the FAERS dataset,
calculating various metrics such as the Reporting Odds Ratio (ROR), Proportional Reporting Ratio (PRR),
Relative Reporting Ratio (RRR), and Information Component (IC).
Contrary to \code{disproportionality_analysis()}, it calculates the association based on number of reports,
and not based on the Drug and Reac database.
For a more flexible application of other disproportionality measures,
you can look at \href{https://CRAN.R-project.org/package=pvda}{this vignette}
of the pvda R package.
}
\details{
The function constructs a contingency table for the drug-event combination and computes the following metrics:
\describe{
\item{\code{ROR}}{Reporting Odds Ratio: Based on odds ratio}
\item{\code{PRR}}{Proportional Reporting Ratio: The expected probability of the event is calculated on the population not having the drug of interest.}
\item{\code{RRR}}{Relative Reporting Ratio: The expected probability of the event is calculated on the entire population.}
\item{\code{IC}}{Information Component: A measure based on Bayesian confidence propagation neural network models. It is the log2 of the shrinked RRR.}
\item{\code{IC_gamma}}{Gamma distribution-based Information Component: An alternative IC calculation using the gamma distribution. It is more appropriate for small databases}
}
}
\examples{
# Example usage
disproportionality_comparison(
  drug_count = 100, event_count = 50,
  drug_event_count = 10, tot = 10000
)

}
\seealso{
Other disproportionality functions: 
\code{\link{disproportionality_analysis}()},
\code{\link{disproportionality_trend}()}
}
\concept{disproportionality functions}

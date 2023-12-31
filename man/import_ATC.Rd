% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import.R
\name{import_ATC}
\alias{import_ATC}
\title{Import ATC classification}
\usage{
import_ATC(primary = T)
}
\arguments{
\item{primary}{Whether only the primary ATC should be retrieved.}
}
\value{
A data frame containing the dataset for ATC linkage.
}
\description{
This function reads the ATC (Anatomical Therapeutic Chemical) classification
from an external source and assigns it to a global environment variable.
}
\examples{
\dontrun{
import_ATC()
}

}

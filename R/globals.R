utils::globalVariables(c("primaryid"))

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to DiAna package. A tool for standardized, flexible, and transparent pharmacovigilance analyses on the FAERS.")
  packageStartupMessage()
  packageStartupMessage(paste0("To cite this package in your work and publications use: ", DiAna_reference()[2]))
  packageStartupMessage()
  packageStartupMessage(DiAna_reference()[4])
  packageStartupMessage()
  packageStartupMessage(DiAna_reference()[6])
}

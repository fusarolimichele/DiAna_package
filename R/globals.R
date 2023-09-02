utils::globalVariables(c("primaryid"))

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to DiAna package. A tool for standardized, flexible, and transparent disproportionality analysis on the FAERS.")
  packageStartupMessage("We have invested a lot of time and effort in creating DiAna, please cite it when using it for data analysis. To cite package ‘DiAna’ in publications use:

  Fusaroli M, Giunchi V (2023). _DiAna: Advanced
  Disproportionality Analysis in the FAERS for Drug
  Safety_.
  https://github.com/fusarolimichele/DiAna_package,
  https://github.com/fusarolimichele/DiAna,
  https://osf.io/zqu89/.")
}

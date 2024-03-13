#' Get DiAna reference
#'
#' This function provides the DiAna reference, that should be used when using DiAna
#'
#' @return DiAna reference
#' @export
#'
#' @examples
#' \dontrun{
#' # DiAna_reference()
#' }
DiAna_reference <- function() {
  print(paste0("To cite package ‘DiAna’ in publications use:

  Fusaroli M., Giunchi V. - DiAna version ", packageVersion("DiAna"), " (", packageDate("DiAna"), "). Advanced
  Disproportionality Analysis in the FAERS for Drug
  Safety.
  https://github.com/fusarolimichele/DiAna_package,
  https://github.com/fusarolimichele/DiAna,
  https://osf.io/zqu89/."))
}

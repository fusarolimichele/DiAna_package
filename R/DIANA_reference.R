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
  print(
    c(
      paste0(
        "Fusaroli M., Giunchi V. - DiAna version ", packageVersion("DiAna"), " (", packageDate("DiAna"), "). ",
        "An open access toolkit for DIsproportionality ANAlysis and other pharmacovigilance investigations in the FAERS. https://github.com/fusarolimichele/DiAna_package; https://github.com/fusarolimichele/DiAna; https://osf.io/zqu89/."
      ),
      paste0("Additional reference: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4.")
    )
  )
}

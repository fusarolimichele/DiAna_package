#' Get DiAna reference
#'
#' This function provides the DiAna reference, that should be used when using DiAna.
#' @param print Logical, should the output be printed? Default to TRUE.
#' @return DiAna reference
#' @importFrom utils packageDate packageVersion
#' @export
#'
#' @examples
#' DiAna_reference()
#'
DiAna_reference <- function(print = TRUE) {
  c(
    paste0("To cite this package in your work and publications use:"),
    paste0(
      "Fusaroli M., Giunchi V. - DiAna version ", utils::packageVersion("DiAna"), " (", utils::packageDate("DiAna"), "). ",
      "An open-source toolkit for DIsproportionality ANAlysis and other pharmacovigilance investigations in the FAERS. https://github.com/fusarolimichele/DiAna_package; https://github.com/fusarolimichele/DiAna; https://osf.io/zqu89/."
    ),
    paste0(""),
    paste0("DiAna contributors for specific functions were: Zoffoli V. for helping developing the cleaning procedure for the FAERS, Van Holle L. for time to onset analysis (cfr. https://doi.org/10.1002/pds.3226), Sakai T. and Trinh N. for pregnancy algorithm (cfr. 10.3389/fphar.2022.1063625)"),
    paste0(""),
    paste0("Additional reference: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4.")
  )
}

#' Get specifics of dictionaries used in database version
#'
#' This function provides specifics on dictionaries used for cleaning the specified database version
#'
#' @return Specifics
#' @param quarter The quarter for which specifics are needed. Default to FAERS_version.
#' @param print Logical, should the output be printed? Default to TRUE.
#' @export
#'
#' @examples
#' FAERS_quarter_specifics("24Q1")
FAERS_quarter_specifics <- function(quarter = FAERS_version, print = TRUE) {
  base::union(
    c(
      paste0("The DiAna dictionary used to convert drugnames to substances is ", quarter),
      paste0("If a reference is needed use: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4.")
    ),
    if (quarter == "24Q1") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 26.1)"
        )
      )
    } else if (quarter == "24Q2") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 27.0)"
        )
      )
    } else if (quarter == "24Q3") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 27.1)"
        )
      )
    } else if (quarter == "24Q4") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 27.1)"
        )
      )
    } else if (quarter == "25Q1") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 28.0)"
        )
      )
    } else if (quarter == "25Q2") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 28.1)"
        )
      )
    } else if (quarter == "25Q3") {
      c(
        paste0(""),
        paste0(
          "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
          "version 28.1)"
        )
      )
    } else {
      c("No information concerning the MedDRA version used available for the specified quarter. Note that information is available only from 24Q1 onward")
    }
  )
}

#' Get DiAna reference
#'
#' This function provides the DiAna reference, that should be used when using DiAna.
#' @param print Logical: print the text? Default `TRUE`. The text is also returned, invisibly when printed.
#' @return DiAna reference
#' @importFrom utils packageDate packageVersion
#' @export
#'
#' @examples
#' DiAna_reference()
#'
DiAna_reference <- function(print = TRUE) {
  text <- c(
    paste0("To cite this package in your work and publications use:"),
    paste0(
      "Fusaroli M., Giunchi V. - DiAna version ", utils::packageVersion("DiAna"), " (", utils::packageDate("DiAna"), "). ",
      "An open-source toolkit for DIsproportionality ANAlysis and other pharmacovigilance investigations in the FAERS. https://github.com/fusarolimichele/DiAna_package; https://github.com/fusarolimichele/DiAna_cleaning; https://osf.io/zqu89/."
    ),
    paste0(""),
    paste0("DiAna contributors for specific functions were: Zoffoli V. for helping developing the cleaning procedure for the FAERS, Van Holle L. for time to onset analysis (cfr. https://doi.org/10.1002/pds.3226), Sakai T. and Trinh N. for pregnancy algorithm (cfr. 10.3389/fphar.2022.1063625)"),
    paste0(""),
    paste0("Additional reference: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4.")
  )
  print_lines(text, print)
}

#' Get specifics of dictionaries used in database version
#'
#' This function provides specifics on dictionaries used for cleaning the specified database version
#'
#' @return Specifics
#' @param quarter The quarter for which specifics are needed. Default to FAERS_version.
#' @param print Logical: print the text? Default `TRUE`. The text is also returned, invisibly when printed.
#' @export
#'
#' @examples
#' FAERS_quarter_specifics("24Q1")
FAERS_quarter_specifics <- function(quarter = FAERS_version, print = TRUE) {
  check_workspace_defaults("quarter")
  text <- c(
    paste0("The DiAna dictionary used to convert drugnames to substances is ", quarter),
    paste0("If a reference is needed use: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4.")
  )
  if (quarter %in% names(meddra_versions)) {
    text <- c(
      text, "",
      paste0(
        "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), ",
        "version ", meddra_versions[[quarter]], ")"
      )
    )
  } else {
    text <- c(text, "No information concerning the MedDRA version used available for the specified quarter. Note that information is available only from 24Q1 onward")
  }
  print_lines(text, print)
}

#' MedDRA version used to code each DiAna quarter
#' @noRd
meddra_versions <- c(
  "24Q1" = "26.1", "24Q2" = "27.0", "24Q3" = "27.1", "24Q4" = "27.1",
  "25Q1" = "28.0", "25Q2" = "28.1", "25Q3" = "28.1", "25Q4" = "29.0"
)

#' Print lines of text if requested; return them (invisibly if printed)
#' @noRd
print_lines <- function(text, print) {
  if (isTRUE(print)) {
    writeLines(text)
    return(invisible(text))
  }
  text
}

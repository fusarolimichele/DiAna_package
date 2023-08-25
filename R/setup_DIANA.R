#' setup_DiAna
#'
#' @description
#' Sets up DiAna on the desktop, downloading the cleaned FAERS up to the specified quarter.
#'
#' @param quarter The ones available:
#'       \itemize{
#'                \item \emph{23Q1}
#'                }
#'
#' @return It creates, on the desktop, the directory which will host all the disproportionality analyses. It also download the cleaned FAERS up to the quarter of year specified.
#' @export
#'
#' @examples
#' \dontrun{
#' setup_DiAna()
#' }
setup_DiAna <- function(quarter = "23Q1") {
  # Prompt the user for input
  user_input <- askYesNo("To set up the DiAna folder,
                         internet connection is needed to download almost 2GB of data.
                         Do you want to proceed? (yes/no): ")

  if (user_input == TRUE) {
    options(timeout = max(100000, getOption("timeout")))
    # Check if the folder exists
    dir.create(paste0(here(), "/data"))
    dir.create(paste0(here(), "/projects"))
    dir.create(paste0(here(), "/external_sources"))
  }

  # URL for the DiAna zip file
  if (quarter == "23Q1") {
    DiAna_url <- "https://osf.io/download/epkqf/"
    # Download and extract DiAna data
    zip_path <- paste0(here(), "/data/", quarter, ".zip")
    download.file(DiAna_url, destfile = zip_path)
    unzip(zip_path, exdir = paste0(here(), "/data/"))
    file.remove(zip_path)
    # Remove __MACOSX folder if it exists
    macosx_folder <- paste0(here(), "/data/", "__MACOSX")
    if (file.exists(macosx_folder)) {
      unlink(macosx_folder, recursive = TRUE)
    } else {
      cat("The quarter required is not available on the DiAna OSF")
    }
  }
}

#' Set Up DiAna Environment
#'
#' This function sets up the DiAna environment by creating necessary folders
#' and downloading the DiAna data up to the specified quarter.
#'
#' @param quarter The quarter for which to set up the DiAna environment
#'                (default is "23Q1"). The ones available:
#'       \itemize{
#'                \item \emph{23Q1}
#'                }
#'
#' @return None. The function sets up the environment and downloads data.
#' @export
#'
#' @examples
#' \dontrun{
#' # Set up DiAna environment for the default quarter
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
    }
  } else {
    cat("The quarter required is not available on the DiAna OSF")
  }
}

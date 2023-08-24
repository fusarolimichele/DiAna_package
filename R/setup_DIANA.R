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
    # Get the desktop path
    desktop_path <- file.path(Sys.getenv("USERPROFILE"), "Desktop")

    # Define folder and subfolder paths
    folder <- paste0("~", desktop_path, "/DiAna")
    subfolder <- paste0("~", desktop_path, "/DiAna/data")
    subfolder2 <- paste0("~", desktop_path, "/DiAna/projects")
    # Check if the folder exists
    if (file.exists(subfolder)) {
      cat("The folder already exists\n")
    } else {
      dir.create(folder)
      dir.create(subfolder)
      dir.create(subfolder2)
    }

    # URL for the DiAna zip file
    if (quarter == "23Q1") {
      DiAna_url <- "https://osf.io/download/epkqf/"
    } else {
      cat("The quarter required is not available on the DiAna OSF")
    }

    # Download and extract DiAna data
    download.file(DiAna_url, destfile = file.path(subfolder, paste0(quarter, ".zip")))
    unzip(file.path(subfolder, paste0(quarter, ".zip")), exdir = subfolder)
    file.remove(file.path(subfolder, paste0(quarter, ".zip")))

    # Remove __MACOSX folder if it exists
    macosx_folder <- file.path(subfolder, "__MACOSX")
    if (file.exists(macosx_folder)) {
      unlink(macosx_folder, recursive = TRUE)
    }
  }
}

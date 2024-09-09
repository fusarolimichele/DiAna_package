#' Set Up DiAna Environment
#'
#' This function sets up the DiAna environment by creating necessary folders
#' and downloading the DiAna data up to the specified quarter
#' and DiAna dictionary together with the csv to link drugs with the ATC.
#'
#' @param quarter The quarter for which to set up the DiAna environment
#'                (default is "23Q1"). The ones available:
#'       \itemize{
#'                \item \emph{23Q1}
#'                }
#'        \itemize{
#'                \item \emph{23Q3}
#'                }
#'        \itemize{
#'                \item \emph{23Q4}
#'                }
#'        \itemize{
#'                \item \emph{24Q1}
#'                }
#'        \itemize{
#'                \item \emph{24Q2}
#'                }
#'
#' @param timeout The amount of time after which R stops a task if it is still unfinished.
#'                Default 100000It may be necessary to increase it in the case of a slow connection.
#'
#' @return None. The function sets up the environment and downloads data.
#' @importFrom here here
#' @importFrom utils askYesNo download.file unzip
#' @export
#'
#' @examples
#' \dontrun{
#' # Set up DiAna environment for the default quarter
#' # Run only when needed to download the FAERS datasets for the first time
#' # and at new quarter updates.
#' setup_DiAna()
#' }
setup_DiAna <- function(quarter = "23Q1", timeout = 100000) {
  # Prompt the user for input
  user_input <- utils::askYesNo("To set up the DiAna folder,
                         internet connection is needed to download almost 2GB of data.
                         Do you want to proceed? (yes/no): ")
  if (user_input == TRUE) {
    options(timeout = max(timeout, getOption("timeout")))
    dir.create(paste0(here::here(), "/data"))
    dir.create(paste0(here::here(), "/projects"))
    dir.create(paste0(here::here(), "/external_sources"))
    # URL for the DiAna zip file
    if (!quarter %in% c("23Q1", "23Q3", "23Q4", "24Q1")) {
      stop("The quarter required is not available on the DiAna OSF")
    } else if (quarter == "23Q1") {
      DiAna_url <- "https://osf.io/download/epkqf/"
    } else if (quarter == "23Q3") {
      DiAna_url <- "https://osf.io/download/mb9wj/"
    } else if (quarter == "23Q4") {
      DiAna_url <- "https://osf.io/download/q3jyd/"
    } else if (quarter == "24Q1") {
      DiAna_url <- "https://osf.io/download/7rfgz/"
    } else if (quarter == "24Q2") {
      DiAna_url <- "https://osf.io/download/mw5z6/"
    }
    # Download and extract DiAna data
    zip_path <- paste0(here::here(), "/data/", quarter, ".zip")
    utils::download.file(DiAna_url, destfile = zip_path, mode = "wb")
    utils::unzip(zip_path, exdir = paste0(here::here(), "/data/"))
    file.remove(zip_path)
    # Remove __MACOSX folder if it exists
    macosx_folder <- paste0(here::here(), "/data/", "__MACOSX")
    if (file.exists(macosx_folder)) {
      unlink(macosx_folder, recursive = TRUE)
    }
    utils::download.file("https://osf.io/download/6vm5r/",
      destfile = paste0(here::here(), "/external_sources/ATC_DiAna.csv"),
      mode = "wb"
    )
    utils::download.file("https://osf.io/download/d7ht4/",
      destfile = paste0(here::here(), "/external_sources/DiAna_dictionary.csv"),
      mode = "wb"
    )
    utils::download.file("https://osf.io/download/2tkf3/",
      destfile = paste0(here::here(), "/external_sources/Countries.csv"),
      mode = "wb"
    )
  }
}

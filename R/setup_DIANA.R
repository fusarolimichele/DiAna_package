#' DiAna data available for download
#'
#' OSF download links of the DiAna data, one per FAERS quarter.
#' @noRd
DiAna_quarter_urls <- c(
  "23Q1" = "https://osf.io/download/epkqf/",
  "23Q3" = "https://osf.io/download/mb9wj/",
  "23Q4" = "https://osf.io/download/q3jyd/",
  "24Q1" = "https://osf.io/download/7rfgz/",
  "24Q2" = "https://osf.io/download/mw5z6/",
  "24Q3" = "https://osf.io/download/pg54x/",
  "24Q4" = "https://osf.io/download/w2khx/",
  "25Q1" = "https://osf.io/download/we635/",
  "25Q2" = "https://osf.io/download/f9cra/",
  "25Q3" = "https://osf.io/download/g5fkv/",
  "25Q4" = "https://osf.io/download/sjyn4/"
)

#' Set Up DiAna Environment
#'
#' This function sets up the DiAna environment by creating necessary folders
#' and downloading the DiAna data up to the specified quarter
#' and DiAna dictionary together with the csv to link drugs with the ATC.
#'
#' @param quarter The quarter for which to set up the DiAna environment
#'                (default is "23Q1"). The ones available:
#'                23Q1, 23Q3, 23Q4, 24Q1, 24Q2, 24Q3, 24Q4, 25Q1, 25Q2, 25Q3, 25Q4.
#'
#' @param timeout The amount of time, in seconds, after which R stops a download if it is still unfinished.
#'                Default 100000. It may be necessary to increase it in the case of a slow connection.
#'                The previous value of the `timeout` option is restored when the function ends.
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
  if (!is.character(quarter) || length(quarter) != 1L || !quarter %in% names(DiAna_quarter_urls)) {
    stop("The quarter required is not available on the DiAna OSF. Available quarters: ",
      paste(names(DiAna_quarter_urls), collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (!isTRUE(ask_yes_no(paste0(
    "To set up the DiAna folder, internet connection is needed to download almost 2GB of data.",
    "\nDo you want to proceed?"
  )))) {
    return(invisible(NULL))
  }

  old_options <- options(timeout = max(timeout, getOption("timeout")))
  on.exit(options(old_options), add = TRUE)

  root <- here::here()
  for (folder in c("data", "projects", "external_sources")) {
    dir.create(file.path(root, folder), showWarnings = FALSE)
  }

  # Download and extract DiAna data
  zip_path <- file.path(root, "data", paste0(quarter, ".zip"))
  utils::download.file(DiAna_quarter_urls[[quarter]], destfile = zip_path, mode = "wb")
  utils::unzip(zip_path, exdir = file.path(root, "data"))
  file.remove(zip_path)
  # Remove __MACOSX folder if it exists
  unlink(file.path(root, "data", "__MACOSX"), recursive = TRUE)

  external_files <- c(
    "ATC_DiAna.csv" = "https://osf.io/download/b2p7k/",
    "DiAna_dictionary.csv" = "https://osf.io/download/n2dgz/",
    "Countries.csv" = "https://osf.io/download/2tkf3/"
  )
  for (file_name in names(external_files)) {
    utils::download.file(external_files[[file_name]],
      destfile = file.path(root, "external_sources", file_name),
      mode = "wb"
    )
  }
  invisible(NULL)
}

#' Install RStudio Snippets from GitHub Repository
#'
#' This function installs RStudio code snippets from a specified GitHub repository.
#'
#' @param repo Character. The GitHub repository containing the snippets. Default is "fusarolimichele/DiAna_snippets".
#' @return None. This function is called for its side effects, which include installing RStudio snippets.
#' @importFrom stringr str_detect str_match str_split
#' @importFrom tibble tibble
#' @importFrom jsonlite fromJSON
#' @importFrom httr content GET status_code
#' @importFrom utils modifyList
#' @examples
#' \dontrun{
#' # This example is using internet connection to download snippets to initialize scripts.
#' # It automatically includes snippets among the ones available to the user.
#' # It should not be run at the check.
#' snippets_install_github()
#' }
#' @export
snippets_install_github <- function(repo = "fusarolimichele/DiAna_snippets") {
  if (!askYesNo(paste0(
    "This command will download snippets from a github.",
    "\n If you have snippets with the same name it may overwrite them.",
    "\n Do you want to continue?"
  ), default = FALSE)) {
    stop("The snippets were not downloaded.")
  }
  # Determine the snippet directory based on the operating system
  if (Sys.info()["sysname"] %in% c("Darwin", "Linux")) {
    SNIPPET_DIRECTORY <- "~/.config/rstudio/snippets"
  } else if (Sys.info()["sysname"] == "Windows") {
    SNIPPET_DIRECTORY <- "%appdata%/Roaming/RStudio/snippets/r.snippets"
  } else {
    stop("Unsupported OS")
  }
  # retrieve files
  req <- httr::GET("https://api.github.com/", path = file.path("repos", repo, "contents"), auth = NULL)
  text <- httr::content(req, as = "text")
  parsed <- jsonlite::fromJSON(text, simplifyVector = FALSE)
  if (httr::status_code(req) >= 400) {
    stop("Request failed (", httr::status_code(req), ")\n", parsed$message,
      call. = FALSE
    )
  }
  files <- parsed
  for (f in files) {
    if (f$type != "file" || !stringr::str_detect(f$name, "\\.snippets$")) {
      message("Skipping ", f$name)
      next
    }
    path <- file.path(SNIPPET_DIRECTORY, "r.snippets")
    req <- httr::GET(f$download_url)
    txt <- httr::content(req, as = "text")
    lines <- do.call(c, stringr::str_split(txt, "\\n"))
    d <- tibble::tibble(
      line = lines,
      snippet = stringr::str_match(line, "^snippet (.*)")[, 2],
      group = cumsum(!is.na(snippet))
    )
    snippets <- d %>%
      split(d$group) %>%
      lapply(function(d) paste(d$line[-1], collapse = "\n"))
    # remove missing snippets
    snippets <- Filter(function(s) s != "", snippets)
    names(snippets) <- d$snippet[!is.na(d$snippet)]
    if (!(file.exists(path))) {
      stop("snippets file ", path, "not found")
    }
    lines <- readLines(path)
    lines <- do.call(c, stringr::str_split(txt, "\\n"))
    d <- tibble::tibble(
      line = lines,
      snippet = stringr::str_match(line, "^snippet (.*)")[, 2],
      group = cumsum(!is.na(snippet))
    )
    snippets <- d %>%
      split(d$group) %>%
      lapply(function(d) paste(d$line[-1], collapse = "\n"))
    # remove missing snippets
    snippets <- Filter(function(s) s != "", snippets)
    names(snippets) <- d$snippet[!is.na(d$snippet)]
    current <- snippets
    current <- utils::modifyList(current, snippets)
    snippet_txt <- paste0("snippet ", names(snippets), "\n",
      as.character(snippets),
      collapse = "\n"
    )
    writeLines(snippet_txt, path)
  }
}

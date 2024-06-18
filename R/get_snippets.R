#' Install RStudio Snippets from GitHub Repository
#'
#' This function installs RStudio code snippets from a specified GitHub repository.
#'
#' @param repo Character. The GitHub repository containing the snippets. Default is "fusarolimichele/DiAna_snippets".
#' @return None. This function is called for its side effects, which include installing RStudio snippets.
#' @examples
#' \dontrun{
#' snippets_install_github()
#' snippets_install_github(repo = "anotheruser/snippets_repo")
#' }
#' @import httr jsonlite stringr dplyr
#' @export
snippets_install_github <- function(repo = "fusarolimichele/DiAna_snippets") {
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
    if (f$type != "file" || !str_detect(f$name, "\\.snippets$")) {
      message("Skipping ", f$name)
      next
    }
    path <- file.path(SNIPPET_DIRECTORY, "r.snippets")
    req <- httr::GET(f$download_url)
    txt <- httr::content(req, as = "text")
    lines <- do.call(c, stringr::str_split(txt, "\\n"))
    d <- dplyr::data_frame(
      line = lines,
      snippet = str_match(line, "^snippet (.*)")[, 2],
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
    d <- dplyr::data_frame(
      line = lines,
      snippet = str_match(line, "^snippet (.*)")[, 2],
      group = cumsum(!is.na(snippet))
    )
    snippets <- d %>%
      split(d$group) %>%
      lapply(function(d) paste(d$line[-1], collapse = "\n"))
    # remove missing snippets
    snippets <- Filter(function(s) s != "", snippets)
    names(snippets) <- d$snippet[!is.na(d$snippet)]
    current <- snippets
    current <- modifyList(current, snippets)
    snippet_txt <- paste0("snippet ", names(snippets), "\n",
      as.character(snippets),
      collapse = "\n"
    )
    writeLines(snippet_txt, path)
  }
}

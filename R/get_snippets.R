#' Install RStudio Snippets from GitHub Repository
#'
#' This function installs RStudio code snippets from a specified GitHub repository.
#' The downloaded snippets are merged into the user's existing R snippets file:
#' snippets with the same name are replaced, all the others are kept.
#'
#' @param repo Character. The GitHub repository containing the snippets. Default is "fusarolimichele/DiAna_snippets".
#' @return Invisibly, the path of the updated snippets file. This function is called for its side effects, which include installing RStudio snippets.
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
  if (!is_interactive()) {
    stop("snippets_install_github() modifies your RStudio snippets and can only be run interactively.",
      call. = FALSE
    )
  }
  path <- snippets_path()
  if (!file.exists(path)) {
    stop("The RStudio snippets file ", path, " was not found. ",
      "Open Tools > Edit Code Snippets in RStudio, save the R snippets once, and run this function again.",
      call. = FALSE
    )
  }
  if (!isTRUE(ask_yes_no(paste0(
    "This command will download snippets from GitHub and add them to ", path, ".",
    "\nExisting snippets with the same name will be replaced.",
    "\nDo you want to continue?"
  )))) {
    stop("The snippets were not downloaded.", call. = FALSE)
  }

  # retrieve files
  req <- httr::GET("https://api.github.com/", path = file.path("repos", repo, "contents"))
  parsed <- jsonlite::fromJSON(httr::content(req, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
  if (httr::status_code(req) >= 400) {
    stop("Request failed (", httr::status_code(req), ")\n", parsed$message,
      call. = FALSE
    )
  }

  snippets <- parse_snippets(readLines(path, warn = FALSE))
  n_downloaded <- 0L
  for (f in parsed) {
    if (f$type != "file" || !grepl("\\.snippets$", f$name)) {
      next
    }
    req <- httr::GET(f$download_url)
    if (httr::status_code(req) >= 400) {
      stop("Download of ", f$name, " failed (", httr::status_code(req), ").", call. = FALSE)
    }
    downloaded <- parse_snippets(strsplit(httr::content(req, as = "text", encoding = "UTF-8"), "\r?\n")[[1]])
    snippets <- utils::modifyList(snippets, downloaded)
    n_downloaded <- n_downloaded + length(downloaded)
  }
  writeLines(format_snippets(snippets), path)
  message(n_downloaded, " snippets installed in ", path, ".")
  invisible(path)
}

#' Location of the user's RStudio R snippets file
#' @noRd
snippets_path <- function() {
  if (.Platform$OS.type == "windows") {
    dir <- file.path(Sys.getenv("APPDATA"), "RStudio", "snippets")
  } else {
    dir <- file.path(path.expand("~"), ".config", "rstudio", "snippets")
  }
  file.path(dir, "r.snippets")
}

#' Parse the lines of a .snippets file into a named list of snippet bodies
#' @noRd
parse_snippets <- function(lines) {
  is_header <- grepl("^snippet ", lines)
  group <- cumsum(is_header)
  keep <- group > 0
  if (!any(keep)) {
    return(list())
  }
  bodies <- lapply(split(lines[keep], group[keep]), function(x) paste(x[-1], collapse = "\n"))
  names(bodies) <- sub("^snippet ", "", lines[is_header])
  bodies
}

#' Turn a named list of snippet bodies back into the text of a .snippets file
#' @noRd
format_snippets <- function(snippets) {
  paste0("snippet ", names(snippets), "\n", unlist(snippets, use.names = FALSE))
}

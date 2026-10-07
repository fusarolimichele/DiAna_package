#' Check that a dataset has the required columns
#' @noRd
check_columns <- function(dt, cols, arg) {
  if (!is.data.frame(dt)) {
    stop("`", arg, "` must be a data.frame or data.table.", call. = FALSE)
  }
  missing <- setdiff(cols, names(dt))
  if (length(missing) > 0L) {
    stop("`", arg, "` is missing column(s): ",
      paste(missing, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Normalise a selection into a named list of term groups
#'
#' Accepts a character vector (each term is its own group) or a list whose
#' elements are character vectors (or lists) of terms to collapse, as in
#' DiAna. Unnamed groups are labelled by their first term.
#' @noRd
as_term_groups <- function(x, arg) {
  if (is.null(x) || length(x) == 0L) {
    stop("`", arg, "` must contain at least one term.", call. = FALSE)
  }
  if (is.list(x)) {
    groups <- lapply(x, function(e) unique(as.character(unlist(e))))
    nms <- names(x)
    if (is.null(nms)) nms <- rep("", length(groups))
    first <- vapply(groups, function(g) if (length(g)) g[[1]] else "", character(1))
    nms[is.na(nms) | nms == ""] <- first[is.na(nms) | nms == ""]
  } else {
    terms <- unique(as.character(x))
    groups <- as.list(terms)
    nms <- terms
  }
  empty <- lengths(groups) == 0L
  if (any(empty)) stop("`", arg, "` contains empty groups.", call. = FALSE)
  if (anyDuplicated(nms)) stop("`", arg, "` has duplicated group names.", call. = FALSE)
  names(groups) <- nms
  groups
}

#' Unique report IDs for each term group
#' @noRd
pids_by_group <- function(ids, terms, groups) {
  terms <- as.character(terms)
  lapply(groups, function(g) unique(ids[terms %in% g]))
}

#' Intersection of two vectors of unique IDs
#' @noRd
fast_intersect <- function(a, b) a[a %in% b]

#' Wrappers around interactive() and askYesNo(), so tests can mock them
#' @noRd
is_interactive <- function() interactive()

#' @noRd
ask_yes_no <- function(msg) utils::askYesNo(msg, default = FALSE)

#' Check that the selected terms exist in the database
#'
#' Lists the terms that were not found. In an interactive session it then asks
#' whether to stop and revise the query; otherwise it warns and continues.
#' @param selected Character vector or (nested) list of selected terms.
#' @param available Terms present in the database.
#' @param what Plural noun used in the message, e.g. "drugs" or "events".
#' @return Invisibly, the terms that were not found.
#' @noRd
check_terms_found <- function(selected, available, what) {
  not_found <- setdiff(as.character(unlist(selected)), as.character(available))
  if (length(not_found) == 0L) {
    return(invisible(character(0)))
  }
  msg <- paste0(
    "Not all the ", what, " selected were found in the database. ",
    "Check these terms for misspellings or alternative nomenclature: ",
    paste(not_found, collapse = "; "), "."
  )
  if (!is_interactive()) {
    warning(msg, call. = FALSE)
    return(invisible(not_found))
  }
  message(msg)
  if (isTRUE(ask_yes_no("Would you like to revise the query?"))) {
    stop("Revise the query and run the command again.", call. = FALSE)
  }
  invisible(not_found)
}

#' Warn about groups that match no report
#' @noRd
warn_empty <- function(pids, arg) {
  empty <- names(pids)[lengths(pids) == 0L]
  if (length(empty) > 0L) {
    warning("No reports found in `", arg, "` for: ",
      paste(empty, collapse = ", "), ".",
      call. = FALSE
    )
  }
  invisible(NULL)
}

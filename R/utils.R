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

#' Workspace objects that DiAna functions use as defaults, and how to create them
#' @noRd
workspace_objects <- c(
  Drug = 'import("DRUG")', Reac = 'import("REAC")', Demo = 'import("DEMO")',
  Demo_supp = 'import("DEMO_SUPP")', Indi = 'import("INDI")', Outc = 'import("OUTC")',
  Ther = 'import("THER")', Doses = 'import("DOSES")', Drug_supp = 'import("DRUG_SUPP")',
  Drug_name = 'import("DRUG_NAME")', MedDRA = "import_MedDRA()", ATC = "import_ATC()",
  FAERS_version = 'FAERS_version <- "25Q4"',
  pids_drug = NA, pids_event = NA
)

#' Stop with a clear message when a workspace object is missing
#' @param name Name of the missing object, e.g. "Drug".
#' @param arg Argument whose default needs the object, if any.
#' @noRd
stop_missing_object <- function(name, arg = NULL) {
  how <- workspace_objects[name]
  fix <- if (is.na(how)) "" else paste0("Run `", how, "` first")
  if (!is.null(arg)) {
    fix <- paste0(fix, if (nzchar(fix)) ", or " else "", "pass `", arg, "` explicitly")
    datasets <- ls(getNamespaceInfo(asNamespace("DiAna"), "lazydata"))
    sample_name <- datasets[tolower(datasets) == tolower(paste0("sample_", name))]
    if (length(sample_name) == 1L) {
      fix <- paste0(fix, " (e.g. `", arg, " = ", sample_name, "`)")
    }
    msg <- paste0("`", arg, "` was not supplied, and its default needs `", name, "`, which was not found in your workspace.")
  } else {
    msg <- paste0("`", name, "` was not found in your workspace.")
  }
  stop(msg, " ", fix, ".", call. = FALSE)
}

#' Check that the defaults of unsupplied arguments can be found
#'
#' Several DiAna functions default to tables in the user's workspace
#' (e.g. `temp_drug = Drug`). For each argument in `args` that the caller did
#' not supply, this checks that the DiAna objects its default refers to exist,
#' without evaluating the default. Call it where the argument is first used.
#' @param args Names of the arguments to check.
#' @noRd
check_workspace_defaults <- function(args) {
  env <- parent.frame()
  defaults <- formals(sys.function(sys.parent()))
  for (arg in args) {
    if (!eval(call("missing", as.name(arg)), env)) next
    needed <- intersect(all.vars(defaults[[arg]]), names(workspace_objects))
    for (name in needed) {
      if (!exists(name, envir = env)) stop_missing_object(name, arg)
    }
  }
  invisible(TRUE)
}

#' Check that an object used directly by a function exists in the workspace
#' @noRd
check_workspace_object <- function(name) {
  if (!exists(name, envir = parent.frame())) stop_missing_object(name)
  invisible(TRUE)
}

#' Root folder of the DiAna project, where data/ and external_sources/ live
#'
#' A wrapper around here::here(), so tests can point it to a temporary folder.
#' @noRd
diana_root <- function() here::here()

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

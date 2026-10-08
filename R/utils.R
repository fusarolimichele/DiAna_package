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

#' Get the MedDRA or ATC dictionary, reading the file only when needed
#'
#' Uses, in order: the table passed by the user; the table already in the
#' caller's workspace (e.g. `MedDRA` loaded with import_MedDRA()); the file in
#' external_sources/. This avoids re-reading the file on every call.
#' @param table The table passed by the user, or NULL.
#' @param name "MedDRA" or "ATC".
#' @noRd
get_dictionary <- function(table, name = c("MedDRA", "ATC")) {
  name <- match.arg(name)
  if (!is.null(table)) {
    return(table)
  }
  env <- parent.frame()
  if (exists(name, envir = env)) {
    return(get(name, envir = env))
  }
  if (name == "MedDRA") {
    import_MedDRA(env = environment())
  } else {
    import_ATC(env = environment())
  }
}

#' Reporting odds ratio from a 2x2 table, with Fisher's exact test
#'
#' The conditional maximum likelihood estimate of the odds ratio, its 95%
#' confidence interval and the p-value of Fisher's exact test.
#' @param tab A 2x2 matrix.
#' @noRd
fisher_or <- function(tab) {
  ft <- stats::fisher.test(tab)
  list(OR = unname(ft$estimate), lower = ft$conf.int[1], upper = ft$conf.int[2], p = ft$p.value)
}

#' Reporting odds ratio for many drug-event combinations
#'
#' Fisher's exact test on the 2x2 table of each combination. The estimates are
#' rounded down to two decimals, as reported by DiAna.
#' @param D_E,D_nE,nD_E,nD_nE Vectors of counts: reports with drug and event,
#'   drug without event, event without drug, neither.
#' @return A list of four vectors: ROR_median, ROR_lower, ROR_upper, p_value_fisher.
#' @noRd
ror_fisher <- function(D_E, D_nE, nD_E, nD_nE) {
  res <- vapply(seq_along(D_E), function(i) {
    or <- fisher_or(matrix(c(D_E[i], nD_E[i], D_nE[i], nD_nE[i]), nrow = 2))
    c(or$OR, or$lower, or$upper, or$p)
  }, numeric(4))
  list(
    ROR_median = floor(res[1, ] * 100) / 100,
    ROR_lower = floor(res[2, ] * 100) / 100,
    ROR_upper = floor(res[3, ] * 100) / 100,
    p_value_fisher = res[4, ]
  )
}

#' Information component (BCPNN) for many drug-event combinations
#'
#' The IC with its approximate 95% credibility interval (Noren et al.), with
#' the shrinkage of 0.5, rounded down to two decimals. Vectorised over the
#' combinations.
#' @param D_E Reports with drug and event; D reports with drug; E reports
#'   with event; TOT all reports.
#' @return A list of three vectors: IC_median, IC_lower, IC_upper.
#' @noRd
ic_bcpnn <- function(D_E, D, E, TOT) {
  IC_median <- log2((D_E + .5) / (((D * E) / TOT) + .5))
  IC_lower <- floor((IC_median - 3.3 * (D_E + .5)^(-1 / 2) - 2 * (D_E + .5)^(-3 / 2)) * 100) / 100
  IC_upper <- floor((IC_median + 2.4 * (D_E + .5)^(-1 / 2) - 0.5 * (D_E + .5)^(-3 / 2)) * 100) / 100
  IC_median <- floor(IC_median * 100) / 100
  list(IC_median = IC_median, IC_lower = IC_lower, IC_upper = IC_upper)
}

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

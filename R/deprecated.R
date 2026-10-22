#' Deprecated functions in DiAna
#'
#' These functions still work, but give a warning and will be removed in a
#' future release of DiAna. Use the replacement instead:
#' \itemize{
#'   \item `hierarchycal_rates()`: use [hierarchical_rates()]. The name was
#'     misspelled; the function is otherwise unchanged.
#'   \item `new_descriptive()`: use [descriptive()], which now includes its
#'     features. Pass the tables with the `temp_*` arguments instead of
#'     `database`: for example `temp_demo = sample_Demo` for the sample data,
#'     or `temp_demo = import("DEMO", quarter = "25Q4")` for a quarter.
#' }
#'
#' @param ... Arguments passed on to the replacement function.
#' @return The value of the replacement function.
#' @name DiAna-deprecated
#' @keywords internal
NULL

#' @rdname DiAna-deprecated
#' @export
hierarchycal_rates <- function(...) {
  .Deprecated("hierarchical_rates", package = "DiAna")
  hierarchical_rates(...)
}

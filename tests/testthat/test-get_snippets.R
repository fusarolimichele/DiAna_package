test_that("Snippets are parsed and written back unchanged", {
  lines <- c(
    "snippet lib", "\tlibrary(${1:package})",
    "snippet fun", "\t${1:name} <- function(${2:variables}) {", "\t\t${0}", "\t}"
  )
  parsed <- parse_snippets(lines)
  expect_named(parsed, c("lib", "fun"))
  expect_equal(parsed$lib, "\tlibrary(${1:package})")
  expect_equal(unlist(strsplit(format_snippets(parsed), "\n")), lines)
})

test_that("Downloaded snippets are merged into the existing ones", {
  existing <- parse_snippets(c("snippet lib", "\tlibrary(x)", "snippet mine", "\tmy_code()"))
  downloaded <- parse_snippets(c("snippet lib", "\tlibrary(DiAna)", "snippet diana", "\tsetup_DiAna()"))
  merged <- utils::modifyList(existing, downloaded)
  expect_named(merged, c("lib", "mine", "diana"))
  expect_equal(merged$lib, "\tlibrary(DiAna)")
  expect_equal(merged$mine, "\tmy_code()")
})

test_that("Text before the first snippet header is ignored", {
  expect_named(parse_snippets(c("# comment", "snippet a", "\tb")), "a")
  expect_equal(parse_snippets(character(0)), list())
})

test_that("Snippets are not installed in a non-interactive session", {
  local_mocked_bindings(is_interactive = function() FALSE)
  expect_error(snippets_install_github(), "interactively")
})

test_that("snippets_install_github() merges the downloaded snippets into the user's file", {
  path <- tempfile(fileext = ".snippets")
  writeLines(c("snippet lib", "\tlibrary(x)", "snippet mine", "\tmy_code()"), path)
  listing <- '[{"type": "file", "name": "r.snippets", "download_url": "https://example.org/r.snippets"},
               {"type": "file", "name": "LICENSE", "download_url": "https://example.org/LICENSE"},
               {"type": "dir", "name": "old", "download_url": null}]'
  local_mocked_bindings(
    is_interactive = function() TRUE,
    ask_yes_no = function(msg) TRUE,
    snippets_path = function() path,
    read_url = function(address) {
      if (grepl("api.github.com", address)) {
        listing
      } else {
        "snippet lib\n\tlibrary(DiAna)\nsnippet diana\n\tsetup_DiAna()"
      }
    }
  )
  expect_message(snippets_install_github(), "2 snippets installed")
  merged <- parse_snippets(readLines(path))
  expect_named(merged, c("lib", "mine", "diana"))
  expect_equal(merged$lib, "\tlibrary(DiAna)")
  expect_equal(merged$mine, "\tmy_code()")
})

test_that("snippets_install_github() changes nothing if the user declines or has no snippets file", {
  path <- tempfile(fileext = ".snippets")
  writeLines(c("snippet mine", "\tmy_code()"), path)
  local_mocked_bindings(
    is_interactive = function() TRUE,
    ask_yes_no = function(msg) FALSE,
    snippets_path = function() path,
    read_url = function(address) stop("should not download")
  )
  expect_error(snippets_install_github(), "not downloaded")
  expect_equal(readLines(path), c("snippet mine", "\tmy_code()"))

  local_mocked_bindings(snippets_path = function() tempfile())
  expect_error(snippets_install_github(), "Edit Code Snippets")
})

test_that("snippets_path() points to the RStudio snippets folder", {
  expect_match(snippets_path(), "r\\.snippets$")
  expect_match(snippets_path(), "snippets", fixed = TRUE)
})

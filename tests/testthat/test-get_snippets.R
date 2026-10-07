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

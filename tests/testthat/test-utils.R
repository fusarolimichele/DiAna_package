test_that("No message when all selected terms are found", {
  expect_silent(check_terms_found(list("a", list("b", "c")), c("a", "b", "c"), "drugs"))
})

test_that("Missing terms give a warning in non-interactive sessions", {
  local_mocked_bindings(is_interactive = function() FALSE)
  expect_warning(
    res <- check_terms_found(list("a", "zz"), c("a", "b"), "drugs"),
    "Not all the drugs selected.*zz"
  )
  expect_equal(res, "zz")
})

test_that("In interactive sessions, answering yes stops and no continues", {
  local_mocked_bindings(is_interactive = function() TRUE)
  local_mocked_bindings(ask_yes_no = function(msg) TRUE)
  expect_error(
    expect_message(check_terms_found("zz", "a", "events"), "zz"),
    "Revise the query"
  )
  local_mocked_bindings(ask_yes_no = function(msg) FALSE)
  expect_message(check_terms_found("zz", "a", "events"), "zz")
  # cancelling the dialog returns NA: continue rather than fail
  local_mocked_bindings(ask_yes_no = function(msg) NA)
  expect_message(check_terms_found("zz", "a", "events"), "zz")
})

test_that("Long lists of missing terms do not break the prompt", {
  local_mocked_bindings(is_interactive = function() TRUE)
  local_mocked_bindings(ask_yes_no = function(msg) FALSE)
  many <- paste0("misspelled term number ", 1:30)
  expect_message(check_terms_found(many, "a", "events"), "number 30")
  # short list: this case crashed on Windows before the fix
  expect_message(check_terms_found("zz", "a", "events"), "zz")
})

test_that("disproportionality_analysis warns about terms not in the database", {
  local_mocked_bindings(is_interactive = function() FALSE)
  expect_warning(
    disproportionality_analysis(
      drug_selected = c("paracetamol", "paracetamoll"),
      reac_selected = "overdose",
      temp_drug = sample_Drug, temp_reac = sample_Reac
    ),
    "paracetamoll"
  )
})

test_that("as_term_groups() accepts vectors, unnamed and named lists", {
  expect_equal(as_term_groups(c("a", "b", "a"), "x"), list(a = "a", b = "b"))
  expect_equal(as_term_groups(list(c("a", "b"), "c"), "x"), list(a = c("a", "b"), c = "c"))
  expect_equal(as_term_groups(list(grp = list("a", "b")), "x"), list(grp = c("a", "b")))
  expect_error(as_term_groups(character(0), "drug1_selected"), "`drug1_selected` must contain at least one term")
  expect_error(as_term_groups(list(g = character(0)), "x"), "contains empty groups")
  expect_error(as_term_groups(list(g = "a", g = "b"), "x"), "duplicated group names")
})

test_that("warn_empty() names the groups without reports", {
  expect_warning(warn_empty(list(a = 1:2, b = integer(0)), "drug1_selected"), "drug1_selected` for: b")
  expect_silent(warn_empty(list(a = 1:2), "drug1_selected"))
})

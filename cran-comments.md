## Submission

This is the first submission of DiAna to CRAN.

## Test environments

* local: macOS (aarch64), R 4.6.0
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release, oldrel-1)
* win-builder: R-devel, R-release (TODO: run devtools::check_win_devel() and check_win_release() after the merge, then update)
* mac-builder: R-release (TODO: run devtools::check_mac_release(), then update)
* R-hub (TODO: run rhub::rhub_check(), then list the platforms)

## R CMD check results

0 errors | 0 warnings | 1 note

* New submission.

* Suggests or Enhances not in mainstream repositories: pvOmega

  pvOmega, developed at the Uppsala Monitoring Centre, is available from
  GitHub (https://github.com/Uppsala-Monitoring-Centre/pvOmega). It is used
  only by omega_analysis(), which checks for it with requireNamespace() and
  explains how to install it if it is missing. Its example and tests are
  skipped when it is not installed.

* The capitals in the Title, "DIsproportionality ANAlysis", are intentional:
  they show where the package name comes from (DIANA, from the first letters
  of the two words).

* Possibly misspelled words in DESCRIPTION (if reported): FAERS (the FDA
  Adverse Event Reporting System, spelled out in the Description),
  pharmacovigilance, disproportionality and "al" (in "et al.") are correct.

## Examples

* Examples run on small sample datasets shipped with the package.
* Examples of functions that need the full cleaned FAERS data (about 2 GB,
  downloaded with setup_DiAna()) or MedDRA (which requires a subscription)
  are run only if those files are present.
* setup_DiAna() and snippets_install_github() examples are in \dontrun{}:
  the first downloads about 2 GB of data, the second modifies the user's
  RStudio snippets and runs only interactively, after the user agrees.
* No example, test or default writes to the user's file space: files are
  written only when a file name is given, and tests use tempdir().

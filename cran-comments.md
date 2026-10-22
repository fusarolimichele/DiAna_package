## Submission

This is the first submission of DiAna to CRAN.

## Test environments

* local: macOS (aarch64), R 4.6.0
* GitHub Actions: macOS (release), Windows (release), Ubuntu (devel, release, oldrel-1)
* win-builder: R-release (R 4.6.1) and R-devel (2026-10-08 r90650), Windows Server 2022
* mac-builder: R-release (TODO: run devtools::check_mac_release(), then update)
* R-hub: linux, macos, windows (all R-devel), nosuggests

## R CMD check results

0 errors | 0 warnings | 1 note

* New submission.

* Suggests or Enhances not in mainstream repositories: PVomega

  PVomega is developed by the Uppsala Monitoring Centre, where the Omega
  drug-drug interaction measure (Noren et al. 2008) was introduced, and is
  available from GitHub (https://github.com/Uppsala-Monitoring-Centre/PVomega).
  As CRAN policy asks, the Description field says where to get it.

  PVomega is optional and is used by only one function, omega_analysis(),
  which calls it as PVomega::omega_from_counts(). It is never attached or
  loaded otherwise:

  - omega_analysis() checks for it with requireNamespace() and, if it is
    missing, stops with a message explaining how to install it.
  - The example of omega_analysis() runs only if requireNamespace("PVomega")
    succeeds, and its tests use skip_if_not_installed("PVomega").
  - The only article that uses PVomega is for the pkgdown website and is
    excluded from the package build (vignettes/articles is in .Rbuildignore).
  - The package passes R CMD check without any suggested packages installed
    (R-hub "nosuggests" platform), and win-builder, where PVomega is not
    available, reports no problem beyond this note.

* The capitals in the Title, "DIsproportionality ANAlysis", are intentional:
  they show where the package name comes from (DIANA, from the first letters
  of the two words).

* Possibly misspelled words in DESCRIPTION: FAERS (the FDA Adverse Event
  Reporting System, spelled out in the Description), Pharmacovigilance,
  disproportionality, DIsproportionality and ANAlysis (see above), the
  author names Fusaroli and Noren, and "et al." are all correct.

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

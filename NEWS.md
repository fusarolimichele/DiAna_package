# DiAna (development version)

## Bug fixes
* `network_analysis()` now applies `min_frequency_term` for `entity = "reaction"` and `entity = "indication"`. Previously the filter was silently skipped, so every term entered the network: **results of earlier reaction and indication networks may differ**. Analyses are also much faster (the example went from about 140 s to 2 s).
* `network_analysis()` no longer draws an extra IsingFit plot or prints a progress bar.
* `retrieve()` no longer fails when a MedDRA table is passed as `temp_meddra`, and uses only the primary ATC code when `temp_atc` is given.
* `disproportionality_analysis()` and `time_to_onset_analysis()`: the check for misspelled drugs and events no longer crashes on Windows. In non-interactive sessions (scripts, R Markdown, batch jobs) it now gives a warning instead of a prompt; previously `time_to_onset_analysis()` stopped in that case.
* `snippets_install_github()` now keeps the user's existing RStudio snippets, replacing only those with the same name, and finds the snippets folder on Windows.
* `setup_DiAna()` checks the quarter before creating any folder, restores the `timeout` option when it ends, and handles a cancelled dialog.

## Dependencies
* 'pvOmega' moved from Imports to Suggests: it is needed only by `omega_analysis()`, which explains how to install it when it is missing.

# DiAna 2.1.1
* Now interoperable with the PVomega package for identifying potential drug-drug interactions (including a function applying it to the DiAna data model)
* Now interoperable with the PVgravID package for identifying pregnancy reports

# DiAna 2.1.0

## Breaking changes
* Download now faster because dependencies are reduced
* Included tests (coverage > 80%)
* Names of parameters are standardized across functions
* Requires the databases to be uploaded, to make clear to the user which databases are used in each function.
* Give the user the decision to whether save in excel or just keep results of descriptive and retrieve function in the environment. Necessary for testing.

## New features
* Included documented sample data and country dictionary in the package
* Added website
* Added articles/tutorials for setting up subproject and performing a disproportionality analysis on the website
* Improved documentation
* Included running examples

## Minor improvements and fixes
* `disproportionality_analysis()` and related functions are more robust: as they accept different formatting of drug_selected and event selected; they warn about unexpected drug or event terms in the input. meddra/pt_level == "custom" is deprecated as inferred from input.
* `render_forest()` function is more flexible: as it allows for changing the position of the legend. Fixed a bug in providing the colors to be shown.
*Updating descriptive to comply with the most recent version of gtsummary.

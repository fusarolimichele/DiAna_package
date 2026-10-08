# DiAna (development version)

## Deprecated
* `retrieve_pregnancy_pids()` is deprecated and will be removed in the next release: use the PVgravID package (`remotes::install_github("Uppsala-Monitoring-Centre/PVgravID")`), as shown in the article "Pregnancy analyses with PVgravID".
* `hierarchycal_rates()` is renamed `hierarchical_rates()`; the old name still works, with a warning.
* `new_descriptive()` is merged into `descriptive()`; the old name still works, with a warning. Pass the tables with the `temp_*` arguments instead of `database`.

## Changes that may affect your scripts
* `descriptive()` describes seriousness outcomes differently. A report without any recorded outcome is not known to be non-serious, so it is no longer counted as "Non Serious". A new row, "Seriousness recorded", gives the reports that record at least one outcome, and the outcome percentages use only those reports as denominator. By default (`outcome = "each"`) there is one row per outcome type, and a report with several outcomes counts in each; `outcome = "most_severe"` gives one row per report with its most severe outcome. Reporter codes outside the standard list now appear as their own category instead of Unknown, and `num_Substances` (1, 2, 3-5, >5 substances) is included by default.
* Functions no longer write files unless asked: `descriptive()`, `new_descriptive()`, `retrieve()`, `hierarchycal_rates()` (`save_in_excel`) and `network_analysis()` (`save_plot`) save only when you pass a `file_name` or set the argument to `TRUE`. Calls that relied on the default file name now only return the results. `hierarchycal_rates()` now also returns the hierarchy as a data.table.
* `import()`, `import_MedDRA()` and `import_ATC()` assign the table in the environment they are called from (`env = parent.frame()`), instead of always in the global environment. From the console or a script nothing changes. Inside your own functions, the table is now created in the function: pass it on explicitly (e.g. `temp_drug = Drug`).
* ggplot2 is no longer attached by `library(DiAna)`. Call `library(ggplot2)` to customise plots, e.g. `render_forest(...) + theme(...)`. data.table is still attached.
* DiAna now requires R 4.1.0 or later (it already used the `\(x)` syntax).

## Bug fixes
* `hierarchical_rates()` (formerly `hierarchycal_rates()`) works again without first running `import_MedDRA()` or `import_ATC()`, and reads each dictionary at most once. It also accepts `temp_meddra`, `temp_atc`, and the case tables `temp_reac`, `temp_indi` and `temp_drug`.
* `reporting_rates()` reuses the MedDRA and ATC already loaded in your workspace instead of reading the files on every call, and gains `temp_meddra` and `temp_atc` arguments.
* `disproportionality_analysis()` accepts factors as `drug_selected` and `reac_selected` (e.g. a column of `Drug`), instead of failing with a join error.
* `snippets_install_github()` reports the reason when a download fails (e.g. "HTTP status was '404 Not Found'").
* `new_descriptive(database = <quarter>)` no longer replaces `Demo`, `Drug`, `Reac`, `Indi`, `Outc` and `Ther` in your workspace with the subset of analysed cases.
* `retrieve_pregnancy_pids()` now uses its `quarter` argument (it always imported the quarter in `FAERS_version`), and no longer overwrites seven tables in your workspace.
* `disproportionality_trend()` no longer adds a `period` column to your `Demo` table.
* `Fix_DiAna_dictionary_locally()` now works: it no longer needs an undocumented `path` variable, and it replaces the records of the corrected drugs instead of adding the corrected records next to the old ones. It gains `temp_drug` and `temp_drug_name` arguments.
* When an argument defaults to a table that is not in your workspace (e.g. `temp_drug = Drug` without `Drug`), the error now says which table is missing and how to import it, instead of "object 'Drug' not found".
* `network_analysis()` now applies `min_frequency_term` for `entity = "reaction"` and `entity = "indication"`. Previously the filter was silently skipped, so every term entered the network: **results of earlier reaction and indication networks may differ**. Analyses are also much faster (the example went from about 140 s to 2 s).
* `network_analysis()` no longer draws an extra IsingFit plot or prints a progress bar.
* `retrieve()` no longer fails when a MedDRA table is passed as `temp_meddra`, and uses only the primary ATC code when `temp_atc` is given.
* `disproportionality_analysis()` and `time_to_onset_analysis()`: the check for misspelled drugs and events no longer crashes on Windows. In non-interactive sessions (scripts, R Markdown, batch jobs) it now gives a warning instead of a prompt; previously `time_to_onset_analysis()` stopped in that case.
* `snippets_install_github()` now keeps the user's existing RStudio snippets, replacing only those with the same name, and finds the snippets folder on Windows.
* `setup_DiAna()` checks the quarter before creating any folder, restores the `timeout` option when it ends, and handles a cancelled dialog.

## Dependencies
* DiAna no longer depends on questionr, lubridate, httr and stringr, which reduces the packages installed with it from 158 to 130 (questionr alone brought in 22, including shiny). Results are unchanged: the reporting odds ratio is computed with `stats::fisher.test()`, which questionr was calling.
* `disproportionality_analysis()` and `disproportionality_trend()` compute the IC for all combinations at once, and are about a third faster on many combinations.
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

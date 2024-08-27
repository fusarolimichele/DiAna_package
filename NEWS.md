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

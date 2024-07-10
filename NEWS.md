# DiAna 2.1.0

## Major changes
* Removed dependency from tidyverse to make the download faster
* Included tests (coverage > 80%)
* Improved documentation
* Included sample data and country dictionary in the package
* Names of parameters have been standardized across functions
* Requires the databases to be uploaded, to make clear to the user which databases are used in each function.
* Give the user the decision to whether save in excel or just keep results of descriptive and retrieve function in the environment. Necessary for testing.

## Minor changes and bug fixes
* Disproportionality functions are more robust:
  _they accept different formatting of drug_selected and event selected;
  _they warn about unexpected drug or event terms in the input;
  _meddra/pt_level == "custom" is deprecated as inferred from input.
* Render forest function is more flexible:
  _It allows for changing the position of the legend.
  _Fixed a bug in providing the colors to be shown.

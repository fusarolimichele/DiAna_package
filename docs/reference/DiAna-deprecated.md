# Deprecated functions in DiAna

These functions still work, but give a warning and will be removed in a
future release of DiAna. Use the replacement instead:

- `hierarchycal_rates()`: use
  [`hierarchical_rates()`](https://fusarolimichele.github.io/DiAna_package/reference/hierarchical_rates.md).
  The name was misspelled; the function is otherwise unchanged.

- `new_descriptive()`: use
  [`descriptive()`](https://fusarolimichele.github.io/DiAna_package/reference/descriptive.md),
  which now includes its features. Pass the tables with the `temp_*`
  arguments instead of `database`: for example `temp_demo = sample_Demo`
  for the sample data, or `temp_demo = import("DEMO", quarter = "25Q4")`
  for a quarter.

## Usage

``` r
hierarchycal_rates(...)

new_descriptive(
  pids_cases,
  RG = NULL,
  drug = NULL,
  save_in_excel = !missing(file_name),
  file_name = "Descriptives.xlsx",
  vars = c("sex", "Submission", "Reporter", "age_range", "Outcome", "country",
    "continent", "age_in_years", "wt_in_kgs", "Reactions", "Indications", "Substances",
    "num_Substances", "year", "role_cod", "time_to_onset"),
  list_pids = list(),
  method = "independence_test",
  database = "sample"
)
```

## Arguments

- ...:

  Arguments passed on to the replacement function.

- pids_cases:

  A vector of primary IDs for cases.

- RG:

  A vector of primary IDs: reference group. Default is NULL.

- drug:

  A vector of drug names. Default is NULL.

- save_in_excel:

  Whether to also save the results in an Excel file, `file_name`.
  Defaults to `TRUE` only if `file_name` is supplied.

- file_name:

  The name of the Excel file to save the results. Default is
  "Descriptives.xlsx". It only works if save_in_excel is TRUE.

- vars:

  A character vector of variable names to include in the analysis.

- list_pids:

  A list of vectors with primary IDs for custom groups whose
  distribution should be described. Default is an empty list.

- method:

  The method for Chi-square test analysis, either "independence_test" or
  "goodness_of_fit". Default is "independence_test". It applies only for
  comparisons between cases and non-cases.

- database:

  For `new_descriptive()`: `"sample"` for the sample data shipped with
  DiAna, or the name of a folder in `data/` (a FAERS quarter such as
  `"25Q4"`, or `"VigiBase"`) from which the tables are imported.

## Value

The value of the replacement function.

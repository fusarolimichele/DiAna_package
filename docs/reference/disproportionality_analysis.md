# Perform Disproportionality Analysis

performs disproportionality analysis and returns the results, which can
be plotted using
[`render_forest()`](https://fusarolimichele.github.io/DiAna_package/reference/render_forest.md).
Look at the DiAna website fore extensive tutorials to practically use
the function
(`vignette("Disproportionality Analysis", package = "DiAna")`) and to
design and run disproportionality analysis based on expected biases
(`vignette("Causal Inference", package = "DiAna")`) Contrary to
[`disproportionality_comparison()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_comparison.md),
it calculates the association based on the Drug and Reac database, and
not based on number of reports. See
[`disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_trend.md)
for investigating how disproportionality changed through time.

## Usage

``` r
disproportionality_analysis(
  drug_selected,
  reac_selected,
  temp_drug = Drug,
  temp_reac = Reac,
  meddra_level = "pt",
  drug_level = "substance",
  restriction = "none",
  minimum_cases = 3,
  frequentist_threshold = 1,
  log2_threshold = 0,
  multiple_comparison = TRUE,
  store_pids = FALSE,
  save_in_excel = FALSE,
  file_name = "disproportionality_results"
)
```

## Arguments

- drug_selected:

  A list of drugs for analysis. Can be a list of lists (to collapse
  terms together).

- reac_selected:

  A list of adverse events for analysis. Can be a list of lists (to
  collapse terms together).

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- meddra_level:

  The desired MedDRA level for analysis (default is "pt").

- drug_level:

  The desired drug level for analysis (default is "substance"). If set
  to "custom" allows a list of lists for reac_selected (collapsing
  multiple terms).

- restriction:

  Primary IDs to consider for analysis (default is "none", which
  includes the entire population). If set to
  Demo\[!RB_duplicates_only_susp\]\$primaryid, for example, allows to
  exclude duplicates according to one of the deduplication algorithms.

- minimum_cases:

  Threshold of minimum cases for calculating identifyin a signal
  (default is 3).

- frequentist_threshold:

  Threshold for defining the significance of the lower limit of the
  Reporting Odds Ratio (default is 1).

- log2_threshold:

  Threshold for defining the significance of the lower limit of the
  Information Component (default is 0).

- multiple_comparison:

  Logical specifying whether to perform Bonferroni correction for
  multiple testing on the ROR. Default to TRUE. Particularly important
  when running the disproportionality on many combinations.

- store_pids:

  Logical specifying whether to store primaryids recording the drug and
  primaryids recording the event as lists. Default to FALSE.

- save_in_excel:

  Whether to save the outcome in an excel. Defaults to TRUE

- file_name:

  The name of the Excel file to save the results. Default is
  "Descriptives.xlsx". It only works if save_in_excel is TRUE.

## Value

A data.table containing disproportionality analysis results.

## See also

Other disproportionality functions:
[`disproportionality_comparison()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_comparison.md),
[`disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_trend.md)

## Examples

``` r
disproportionality_analysis(
  drug_selected = "paracetamol",
  reac_selected = "overdose",
  temp_drug = sample_Drug,
  temp_reac = sample_Reac
)
#>      substance    event   D_E  D_nE     D  nD_E     E nD_nE ROR_median
#>         <fctr>    <ord> <num> <num> <num> <num> <num> <num>      <num>
#> 1: paracetamol overdose     5    46    51    10    15   939      10.14
#>    ROR_lower ROR_upper IC_median IC_lower IC_upper              label_ROR
#>        <num>     <num>     <num>    <num>    <num>                 <char>
#> 1:      2.61     34.19      2.12     0.55      3.1 10.14 (2.61-34.19) [5]
#>               label_IC Bonferroni ROR_signal IC_signal
#>                 <char>     <lgcl>      <ord>     <ord>
#> 1: 2.12 (0.55-3.1) [5]       TRUE        SDR       SDR
```

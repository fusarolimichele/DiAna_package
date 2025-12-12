# Disproportionality Time Trend for a Drug-Event Combination

This function calculates the disproportionality time trend for a given
drug-event combination. Check
[`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md)
for more options to address biases. Its results can be visualized using
[`plot_disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/plot_disproportionality_trend.md).

## Usage

``` r
disproportionality_trend(
  drug_selected,
  reac_selected,
  temp_drug = Drug,
  temp_reac = Reac,
  temp_demo = Demo,
  temp_demo_supp = Demo_supp[, .(primaryid, quarter)],
  meddra_level = "pt",
  drug_level = "substance",
  restriction = "none",
  time_granularity = "year",
  cumulative = TRUE,
  min_2004 = TRUE
)
```

## Arguments

- drug_selected:

  Drug selected

- reac_selected:

  Event selected

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- temp_demo:

  Demo dataset. Defaults to Demo. Can be se to sample_Demo for testing

- temp_demo_supp:

  Data frame containing supplementary demographic data, and in
  particular the quarter. Defaults to
  `Demo_supp\[, .(primaryid, quarter)\]`.

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

- time_granularity:

  Character string specifying the time granularity. Options are "year",
  "quarter", or "month". Defaults to "year".

- cumulative:

  Logical indicating whether to calculate cumulative values. Defaults to
  `TRUE`.

- min_2004:

  Logical indicating whether to start the analysis only from 2004, year
  of the FDA AERS first implementation. Defaults to `TRUE`.

## Value

A data frame containing the disproportionality results over time,
including:

- period:

  Time period. Deafult is 'year'. Other values are 'quarter' and
  'month'. When using 'quarter' Demo_supp is required

- TOT:

  Total number of reports

- D_E:

  Number of reports with both drug and event

- D_nE:

  Number of reports with the drug but not the event

- D:

  Total number of reports with the drug

- nD_E:

  Number of reports with the event but not the drug

- E:

  Total number of reports with the event

- nD_nE:

  Number of reports with neither the drug nor the event

- ROR_median:

  Reporting odds ratio (ROR) median

- ROR_lower:

  ROR lower bound (2.5%)

- ROR_upper:

  ROR upper bound (97.5%)

- p_value_fisher:

  Fisher's exact test p-value

- Bonferroni:

  Bonferroni-corrected p-value

- IC_median:

  Information component (IC) median

- IC_lower:

  IC lower bound

- IC_upper:

  IC upper bound

- label_ROR:

  Formatted ROR label

- label_IC:

  Formatted IC label

## Details

The function processes the provided data to calculate the reporting odds
ratio (ROR) and the information component (IC) for the specified
drug-event combination over time.

## See also

Other disproportionality functions:
[`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md),
[`disproportionality_comparison()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_comparison.md)

## Examples

``` r
drug_selected <- "paracetamol"
reac_selected <- "overdose"
result <- disproportionality_trend(drug_selected, reac_selected,
  temp_drug = sample_Drug, temp_reac = sample_Reac, temp_demo = sample_Demo,
  temp_demo_supp = sample_Demo_supp[, .(primaryid, quarter)]
)
```

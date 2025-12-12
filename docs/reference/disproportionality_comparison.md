# Disproportionality Analysis for Drug-Event Combinations

This function performs a disproportionality analysis for drug-event
combinations in the FAERS dataset, calculating various metrics such as
the Reporting Odds Ratio (ROR), Proportional Reporting Ratio (PRR),
Relative Reporting Ratio (RRR), and Information Component (IC). Contrary
to
[`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md),
it calculates the association based on number of reports, and not based
on the Drug and Reac database. For a more flexible application of other
disproportionality measures, you can look at [this
vignette](https://CRAN.R-project.org/package=pvda) of the pvda R
package.

## Usage

``` r
disproportionality_comparison(
  drug_count = length(pids_drug),
  event_count = length(pids_event),
  drug_event_count = length(intersect(pids_drug, pids_event)),
  tot = nrow(Demo),
  print_results = TRUE
)
```

## Arguments

- drug_count:

  An integer representing the number of reports for the drug of
  interest. Default is the length of `pids_drug`.

- event_count:

  An integer representing the number of reports for the event of
  interest. Default is the length of `pids_event`.

- drug_event_count:

  An integer representing the number of reports for the drug-event
  combination. Default is the length of the intersection of `pids_drug`
  and `pids_event`.

- tot:

  An integer representing the total number of reports in the dataset.
  Default is the number of rows in the `Demo` table.

- print_results:

  A logical to control whether the results should also be printed,
  besides being stored in the results.

## Value

This function prints a contingency table and several disproportionality
metrics (which are also stored in a list):

- `ROR`: Reporting Odds Ratio with confidence intervals.

- `PRR`: Proportional Reporting Ratio with confidence intervals.

- `RRR`: Relative Reporting Ratio with confidence intervals.

- `IC`: Information Component with confidence intervals.

- `IC_gamma`: Gamma distribution-based Information Component with
  confidence intervals.

## Details

The function constructs a contingency table for the drug-event
combination and computes the following metrics:

- `ROR`:

  Reporting Odds Ratio: Based on odds ratio

- `PRR`:

  Proportional Reporting Ratio: The expected probability of the event is
  calculated on the population not having the drug of interest.

- `RRR`:

  Relative Reporting Ratio: The expected probability of the event is
  calculated on the entire population.

- `IC`:

  Information Component: A measure based on Bayesian confidence
  propagation neural network models. It is the log2 of the shrinked RRR.

- `IC_gamma`:

  Gamma distribution-based Information Component: An alternative IC
  calculation using the gamma distribution. It is more appropriate for
  small databases

## See also

Other disproportionality functions:
[`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md),
[`disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_trend.md)

## Examples

``` r
# Example usage
disproportionality_comparison(
  drug_count = 100, event_count = 50,
  drug_event_count = 10, tot = 10000
)
#>     E   nE
#> D  10   90
#> nD 40 9860
#> 
#> 
#> ROR = 27.32 (11.81-57.83)
#> PRR = 24.75 (12.74-48.1)
#> RRR = 20 (10.44-38.3)
#> IC = 3.39 (2.31-4.11)
#> IC_gamma = 3.35 (2.36-4.15)
```

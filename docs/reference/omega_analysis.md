# Omega drug-drug interaction analysis on DiAna CDM

Computes the Omega interaction measure (Noren et al. 2008) for every
combination of a first drug, a second drug and an adverse event,
starting from the `Drug` and `Reac` tables of the DiAna CDM. The
interface mirrors
[`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md)
and calls the pvOmega package for the calculation.

## Usage

``` r
omega_analysis(
  drug1_selected,
  drug2_selected,
  reac_selected,
  temp_drug = Drug[role_cod %in% c("PS", "SS", "I")],
  temp_reac = Reac,
  restriction = "none",
  minimum_cases = 3,
  log2_threshold = 0,
  store_pids = FALSE,
  save_in_excel = FALSE,
  file_name = "omega_results"
)
```

## Arguments

- drug1_selected:

  First drug(s). A character vector, or a (named) list whose elements
  are character vectors of terms to collapse into one group.

- drug2_selected:

  Second drug(s), same format as `drug1_selected`.

- reac_selected:

  Adverse event(s), same format as `drug1_selected`.

- temp_drug:

  Drug dataset (default `Drug[role_cod%in%c("PS","SS","I")]`, as created
  by `DiAna::import("DRUG")`). Can be set to
  [`DiAna::sample_Drug`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Drug.md)
  for testing.

- temp_reac:

  Reac dataset (default `Reac`). Can be set to
  [`DiAna::sample_Reac`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Reac.md)
  for testing.

- restriction:

  Primary IDs to consider (default `"none"`, the entire population). For
  example `Demo[!RB_duplicates_only_susp]$primaryid` excludes duplicates
  according to one of DiAna's deduplication algorithms.

- minimum_cases:

  Minimum number of cases (`n111`) to flag a signal (default 3). With
  alpha = 0.5, credibility interval 0.95 and the Gamma interval, fewer
  than 3 cases cannot produce `omega_lower > 0` anyway.

- log2_threshold:

  Threshold on `omega_lower` for flagging a signal (default 0).

- store_pids:

  Logical. If `TRUE`, adds a list column `pids_cases` with the primary
  IDs of the reports listing both drugs and the event, useful for
  case-series review. Default `FALSE`.

- save_in_excel:

  Logical. If `TRUE`, writes the results to an Excel file (requires the
  'writexl' package). Default `FALSE`.

- file_name:

  Name of the Excel file (without extension). Only used if
  `save_in_excel = TRUE`.

## Value

A `data.table` with one row per drug1-drug2-event combination: the
labels `drug1`, `drug2`, `event`, all columns returned by
[`omega_from_counts()`](https://rdrr.io/pkg/pvOmega/man/omega_from_counts.html),
`label_omega` and `omega_signal` (an ordered factor:
`"not enough cases"`, `"no SDR"`, `"SDR"`).

## Details

### Report universe

The total number of reports (`n...`) is the number of distinct
`primaryid` in `temp_reac`, intersected with `restriction` when
supplied. All drug and event report sets are intersected with this
universe, so every count refers to the same population. When both
orderings of a drug pair occur (e.g. A-B and B-A), only the first is
kept. Omega is symmetric in the two drugs.

### Drug roles

By default only drugs recorded as primary suspect, secondary suspect or
interacting (`role_cod` in `PS`, `SS`, `I`) count as exposure, following
the approach used at Uppsala Monitoring Centre (Hult et al. 2020). The
universe is not filtered by role: a report where a drug is only
concomitant contributes to the background stratum. Set
`temp_drug = Drug` to count all roles.

### Interpretation

Omega compares the observed number of reports with the number expected
if the two drugs contributed additive, independent risks.
`omega_lower > 0` (Omega025 \> 0 at the default 95% level) indicates
that the combination is reported more often than expected under no
interaction. As for any disproportionality measure, this is a hypothesis
for clinical review, not evidence of a causal interaction. Always
inspect `f00`, `f10`, `f01`, `f11` and `g11` and the case series,
alongside Omega, as recommended in the original paper.

## References

Noren GN, Sundberg R, Bate A, Edwards IR. A statistical methodology for
drug-drug interaction surveillance. Stat Med. 2008;27(16):3057-70.
[doi:10.1002/sim.3247](https://doi.org/10.1002/sim.3247)

Hult S, Sartori D, Bergvall T, et al. A feasibility study of drug-drug
interaction signal detection in regular pharmacovigilance. Drug Saf.
2020;43:775-85.
[doi:10.1007/s40264-020-00939-y](https://doi.org/10.1007/s40264-020-00939-y)

## Examples

``` r
omega_analysis(
  drug1_selected = "paracetamol",
  drug2_selected = "ibuprofen",
  reac_selected = "overdose",
  temp_drug = sample_Drug,
  temp_reac = sample_Reac
)
#>          drug1     drug2    event  n1.1  n.11  n1..  n.1.  n..1  n...  n111
#>         <char>    <char>   <char> <num> <num> <num> <num> <num> <num> <num>
#> 1: paracetamol ibuprofen overdose     5     0    51    15    15  1000     0
#>     n110  n101  n100  n011  n010  n001  n000  n11.  n10.  n01.  n00.       f00
#>    <num> <num> <num> <num> <num> <num> <num> <num> <num> <num> <num>     <num>
#> 1:     6     5    40     0     9    10   930     6    45     9   940 0.0106383
#>          f10   f01   f11       g11      E111     omega omega_lower omega_upper
#>        <num> <num> <num>     <num>     <num>     <num>       <num>       <num>
#> 1: 0.1111111     0     0 0.1111111 0.6666667 -1.222392   -11.21428    1.106411
#>                 label_omega     omega_signal
#>                      <char>            <ord>
#> 1: -1.22 (-11.21; 1.11) [0] not enough cases
```

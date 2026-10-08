# Generate Descriptive Statistics for a Sample

This function generates descriptive statistics for a sample of reports
(cases), optionally compared with a reference group (non-cases), and can
save the results to an Excel file.

## Usage

``` r
descriptive(
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
  outcome = c("each", "most_severe"),
  temp_demo = Demo,
  temp_drug = Drug,
  temp_reac = Reac,
  temp_indi = Indi,
  temp_outc = Outc,
  temp_ther = Ther
)
```

## Arguments

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

- outcome:

  How to describe the seriousness outcomes, when `"Outcome"` is in
  `vars`:

  - `"each"` (default): one row per outcome (Death, Life threatening,
    Disability, Required intervention, Hospitalization, Congenital
    anomaly, Other serious). A report with several outcomes counts in
    each of them, so the percentages do not add up to 100%.

  - `"most_severe"`: one row per report, with its most severe outcome,
    in the order listed above.

  See the section "Outcomes" for the denominator.

- temp_demo:

  Demo dataset. Defaults to Demo. Can be set to sample_Demo for testing

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- temp_indi:

  Indi dataset. Can be set to sample_Indi for testing

- temp_outc:

  Outc dataset. Can be set to sample_Outc for testing

- temp_ther:

  Ther dataset. Can be set to sample_Ther for testing

## Value

The descriptive statistics as a table (a tibble), with counts and
percentages for cases and, if `RG` is given, for non-cases with
p-values. If `save_in_excel = TRUE`, the table is also saved to
`file_name`.

## Outcomes

A FAERS report records seriousness outcomes only when the reporter
provides them. A report without any recorded outcome is **not** known to
be non-serious: the information is simply missing, and nothing can be
said about the seriousness of that report. For this reason:

- the row "Seriousness recorded" gives the number and percentage of
  reports, among all reports, that record at least one outcome;

- the percentages of the outcome rows use as denominator only the
  reports with at least one recorded outcome. Reports without any
  recorded outcome are excluded from that denominator, not counted as
  non-serious.

## Examples

``` r
pids_cases <- unique(sample_Demo[sex == "M"]$primaryid)
RG <- unique(sample_Demo[sex == "F"]$primaryid)

# Generate descriptive statistics for cases
descriptive(
  pids_cases = pids_cases,
  temp_demo = sample_Demo, temp_drug = sample_Drug,
  temp_reac = sample_Reac, temp_indi = sample_Indi,
  temp_outc = sample_Outc, temp_ther = sample_Ther
)
#> Warning: Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated
#> # A tibble: 117 × 3
#>    `**Characteristic**`    N_cases `%_cases`
#>    <chr>                   <chr>   <chr>    
#>  1 N                       355     ""       
#>  2 sex                     NA       NA      
#>  3 Male                    355     "100.00" 
#>  4 Submission              NA       NA      
#>  5 Direct                  24      "6.76"   
#>  6 Expedited               181     "50.99"  
#>  7 Periodic                150     "42.25"  
#>  8 Reporter                NA       NA      
#>  9 Consumer                163     "48.22"  
#> 10 Healthcare practitioner 20      "5.92"   
#> # ℹ 107 more rows

# Generate descriptive statistics for cases and non-cases,
# describing only the most severe outcome of each report
descriptive(
  pids_cases = pids_cases, RG = RG, outcome = "most_severe",
  temp_demo = sample_Demo, temp_drug = sample_Drug,
  temp_reac = sample_Reac, temp_indi = sample_Indi,
  temp_outc = sample_Outc, temp_ther = sample_Ther
)
#> Warning: Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated
#> # A tibble: 135 × 7
#>    `**Characteristic**` N_cases `%_cases` N_controls `%_controls` `**p-value**`
#>    <chr>                <chr>   <chr>     <chr>      <chr>        <chr>        
#>  1 N                    355     ""        538        ""           ""           
#>  2 __sex__              NA       NA       NA          NA          "<0.001"     
#>  3 Female               0       "0.00"    538        "100.00"      NA          
#>  4 Male                 355     "100.00"  0          "0.00"        NA          
#>  5 __Submission__       NA       NA       NA          NA          "0.251"      
#>  6 Direct               24      "6.76"    39         "7.25"        NA          
#>  7 Expedited            181     "50.99"   244        "45.35"       NA          
#>  8 Periodic             150     "42.25"   255        "47.40"       NA          
#>  9 __Reporter__         NA       NA       NA          NA          "0.763"      
#> 10 Consumer             163     "48.22"   254        "50.20"       NA          
#> # ℹ 125 more rows
#> # ℹ 1 more variable: `**q-value**` <chr>
```

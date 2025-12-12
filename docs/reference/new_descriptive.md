# Generate Descriptive Statistics for a Sample

This function generates descriptive statistics for a sample of data,
including cases and non-cases, and saves the results to an Excel file.

## Usage

``` r
new_descriptive(
  pids_cases,
  RG = NULL,
  drug = NULL,
  save_in_excel = TRUE,
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

- pids_cases:

  A vector of primary IDs for cases.

- RG:

  A vector of primary IDs: reference group. Default is NULL.

- drug:

  A vector of drug names. Default is NULL.

- save_in_excel:

  Whether to save the outcome in an excel. Defaults to TRUE

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

  Database on which to run the analysis. By default "sample".

## Value

The function generates descriptive statistics as a gt_table and
potentially saves them to an Excel file.

## Examples

``` r
pids_cases <- unique(sample_Demo[sex == "M"]$primaryid)
RG <- unique(sample_Demo[sex == "M"]$primaryid)

# Generate descriptive statistics for cases
new_descriptive(
  pids_cases = pids_cases, save_in_excel = FALSE
)
#> Warning: Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated
#> # A tibble: 122 × 3
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
#> # ℹ 112 more rows

# Generate descriptive statistics for cases and non-cases
new_descriptive(
  pids_cases = pids_cases, RG = RG, save_in_excel = FALSE
)
#> Warning: Variables role_cod and time_to_onset not considered. If you want to include them please provide the drug investigated
#> Warning: NAs introduced by coercion
#> Warning: number of columns of result, 6, is not a multiple of vector length 7 of arg 1
#> # A tibble: 122 × 6
#>    `**Characteristic**`  N_cases `%_cases` N_controls `%_controls` `**q-value**`
#>    <chr>                 <chr>   <chr>     <chr>      <chr>        <chr>        
#>  1 N                     355     ""        NA         ""           ""           
#>  2 __sex__               NA       NA       NA         NA           NA           
#>  3 Male                  355     "100.00"  NA         NA           NA           
#>  4 __Submission__        NA       NA       NA         NA           NA           
#>  5 Direct                24      "6.76"    NA         NA           NA           
#>  6 Expedited             181     "50.99"   NA         NA           NA           
#>  7 Periodic              150     "42.25"   NA         NA           NA           
#>  8 __Reporter__          NA       NA       NA         NA           NA           
#>  9 Consumer              163     "48.22"   NA         NA           NA           
#> 10 Healthcare practitio… 20      "5.92"    NA         NA           NA           
#> # ℹ 112 more rows
```

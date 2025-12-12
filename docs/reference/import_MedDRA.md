# Import MedDRA Data

This function imports MedDRA (Medical Dictionary for Regulatory
Activities) data from a CSV file and stores it in the global
environment.

## Usage

``` r
import_MedDRA(env = .GlobalEnv)
```

## Arguments

- env:

  The environment where the data will be assigned. Default to .GlobalEnv

## Value

A data table containing MedDRA data.

## Details

This function reads MedDRA data from a CSV file located at the path
specified by `here()/external_sources/meddra_primary.csv`. If the file
does not exist, it will stop execution and provide instructions on how
to obtain MedDRA data. If the file exists, it will load the data, select
specific columns (def, soc, hlgt, hlt, pt), remove duplicates, and store
it in the global environment as "MedDRA".

## See also

You can find more information and instructions for obtaining MedDRA data
at https://github.com/fusarolimichele/DiAna.

## Examples

``` r
# This example requires a specific file that can only be available with a MeDRA subscription.
if (file.exists("external_source/meddra_primary.csv")) {
  import_MedDRA()
}
```

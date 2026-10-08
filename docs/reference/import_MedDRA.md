# Import MedDRA Data

This function imports MedDRA (Medical Dictionary for Regulatory
Activities) data from a CSV file and assigns it as `MedDRA` in `env`.

## Usage

``` r
import_MedDRA(env = parent.frame())
```

## Arguments

- env:

  The environment where the table is assigned. Defaults to the
  environment
  [`import()`](https://fusarolimichele.github.io/DiAna_package/reference/import.md)
  is called from: your workspace when called from the console or a
  script, or the calling function's own environment when called inside a
  function.

## Value

A data table containing MedDRA data.

## Details

This function reads MedDRA data from a CSV file located at the path
specified by `here()/external_sources/meddra_primary.csv`. If the file
does not exist, it will stop execution and provide instructions on how
to obtain MedDRA data. If the file exists, it will load the data, select
specific columns (def, soc, hlgt, hlt, pt), remove duplicates, and
assign it as `MedDRA` in `env` (by default, the environment it is called
from).

## See also

You can find more information and instructions for obtaining MedDRA data
at https://github.com/fusarolimichele/DiAna_cleaning.

## Examples

``` r
# This example requires a specific file that can only be available with a MeDRA subscription.
if (file.exists(file.path(here::here(), "external_sources", "meddra_primary.csv"))) {
  import_MedDRA()
}
```

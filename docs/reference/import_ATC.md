# Import ATC classification

This function reads the ATC (Anatomical Therapeutic Chemical)
classification from an external source and assigns it as `ATC` in `env`
(by default, the environment it is called from).

## Usage

``` r
import_ATC(primary = TRUE, env = parent.frame())
```

## Arguments

- primary:

  Whether only the primary ATC should be retrieved.

- env:

  The environment where the table is assigned. Defaults to the
  environment
  [`import()`](https://fusarolimichele.github.io/DiAna_package/reference/import.md)
  is called from: your workspace when called from the console or a
  script, or the calling function's own environment when called inside a
  function.

## Value

A data frame containing the dataset for ATC linkage.

## Examples

``` r
if (file.exists(file.path(here::here(), "external_sources", "ATC_DiAna.csv"))) {
  import_ATC()
}
```

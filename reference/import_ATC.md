# Import ATC classification

This function reads the ATC (Anatomical Therapeutic Chemical)
classification from an external source and assigns it to a global
environment variable.

## Usage

``` r
import_ATC(primary = T, env = .GlobalEnv)
```

## Arguments

- primary:

  Whether only the primary ATC should be retrieved.

- env:

  The environment where the data will be assigned. Default to .GlobalEnv

## Value

A data frame containing the dataset for ATC linkage.

## Examples

``` r
if (file.exists("external_source/ATC_DiAna.csv")) {
  import_ATC()
}
```

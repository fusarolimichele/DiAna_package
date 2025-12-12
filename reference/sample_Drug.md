# Sample Data on Drug Administration

A dataset containing information on drugs administered to individuals,
including substance names, and roles.

## Usage

``` r
sample_Drug
```

## Format

A data.table with 4 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- drug_seq:

  Sequence number identifying the specific drug in the report
  (`integer`).

- substance:

  Name of the drug substance (active ingredient), as standardized using
  DiAna_Dictionary (`factor`).

- role_cod:

  Role code indicating the role of the drug (`ordered`), with levels
  `PS` for primary suspect, `SS` for secondary suspect, `C` for
  concomitant, `I` for interacting.

## Source

https://github.com/fusarolimichele/DiAna

## Details

This subset of Drug provides detailed information on drugs administered
to individuals, specifying their suspected roles in the context of
adverse drug reactions.

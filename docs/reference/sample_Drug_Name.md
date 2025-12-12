# Sample Data on Drug Names before standardization

A dataset containing information on drug names and associated details,
including drug names, and additional attributes.

## Usage

``` r
sample_Drug_Name
```

## Format

A data.table with 5 variables:

- primaryid:

  Unique identifier for each report (`numeric`).

- drug_seq:

  Sequence number identifying the specific drug in the report
  (`integer`).

- val_vbm:

  Validity flag indicating whether the drug name is valid or a free text
  (not reliable) (`integer`).

- nda_num:

  New Drug Application number (`character`).

- drugname:

  Name of the drug as recorded by the reporter (`factor`).

- prod_ai:

  Product active ingredient as recorded by the reporter (`factor`).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This subset of Drug_Name provides detailed information on drug names and
associated attributes.

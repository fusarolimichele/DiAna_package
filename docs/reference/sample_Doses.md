# Sample Data on Drug Doses

A dataset containing information on drug doses administered, linking
primary IDs with dose details.

## Usage

``` r
sample_Doses
```

## Format

A data.table with 7 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- drug_seq:

  Sequence number identifying the specific drug in the report
  (`integer`).

- dose_vbm:

  Verbatim (free-text) dose description (`character`).

- dose_unit:

  Unit of dose (`character`).

- cum_dose_chr:

  Cumulative dose as character (`numeric`).

- dose_amt:

  Amount of dose (`character`).

- cum_dose_unit:

  Cumulative dose unit (`character`).

- dose_freq:

  Frequency of dose (`factor`).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This subset of Doses provides detailed information on drug doses
administered, including verbatim descriptions, units, cumulative doses,
amounts, and frequency of administration, facilitating analysis related
to dosing patterns. As it can be observed in the sample, most of the
dataset is NA (info not available).

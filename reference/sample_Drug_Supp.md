# Sample Supplementary Drug Information

A dataset containing supplementary information on drugs administered,
including administration routes, formulation, and related details.

## Usage

``` r
sample_Drug_Supp
```

## Format

A data.table with 8 variables:

- primaryid:

  Unique identifier for each report (`numeric`).

- drug_seq:

  Sequence number identifying the specific drug in the report
  (`integer`).

- route:

  Route of drug administration (`factor`).

- dose_form:

  Form of the drug dose (`factor`).

- dechal:

  Dechallenged flag indicating if dechallenge verified: the event abated
  at the discontinuation of the drug (`factor`).

- rechal:

  Rechallenged flag indicating if rechallenge verified: the event
  reappeared after readminstering the drug (`factor`).

- lot_num:

  Lot number of the drug (`character`).

- exp_dt:

  Expiration date of the drug (`numeric`).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This dataset provides supplementary information on drugs administered,
including details such as administration routes, dose forms, and
dechallenge/rechallenge flags. It complements adverse drug reaction data
by providing additional context on drug usage.

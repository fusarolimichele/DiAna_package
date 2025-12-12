# Sample Data on Individual Outcomes

A dataset containing individual-level outcomes associated with adverse
drug reactions, linking primary IDs with outcome codes.

## Usage

``` r
sample_Outc
```

## Format

A data.table with 2 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- outc_cod:

  Outcome code indicating the severity or outcome of the adverse event
  (`ordered`), with levels `DE` for death, `LT` for life-threatening,
  `HO` for hospitalization, `DS` for disability, `RI` for required
  intervention, `OT` for other

## Source

https://github.com/fusarolimichele/DiAna

## Details

This dataset provides information on outcomes associated with reported
adverse drug reactions, specifying the severity or nature of each event
observed for individuals.

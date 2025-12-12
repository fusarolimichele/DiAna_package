# Sample dataset containing events (suspected adverse drug reactions) and related information.

This dataset provides information on adverse drug reactions (ADRs). Each
report (primaryid) can record multiple events (and rows).

## Usage

``` r
sample_Reac
```

## Format

A data.table with 3 variables:

- primaryid:

  Unique identifier for the report (primary ID)

- pt:

  Preferred term describing the adverse reaction according to the
  Medical Dictionary for Regulatory Activities

- drug_rec_act:

  Drug rechallenged action (if the event recurred at the rechallenge, it
  is going to be shown here).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This dataset is a subset of the actual Reac data (that can be downloaded
using setup_DiAna()), providing a glimpse into the structure of the
database and allowing tests and documentation.

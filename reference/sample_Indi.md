# Sample dataset containing indications for using reported drugs.

This dataset provides information on indications. Each report
(primaryid) can record multiple drugs and therefore multiple indications
(and rows).

## Usage

``` r
sample_Indi
```

## Format

A data.table with 3 variables:

- primaryid:

  Unique identifier for each report.

- drug_seq:

  Sequence number identifying a specific drug reported in a report.

- indi_pt:

  Preferred term describing the drug indication according to the Medical
  Dictionary for Regulatory Activities.

## Source

https://github.com/fusarolimichele/DiAna

## Details

This dataset provides detailed information on drug indications reported
for individuals, categorized by primary ID and drug sequence,
facilitating analysis related to specific indications observed in
adverse drug reaction reports. Each report can record multiple drugs and
therefore multiple indications.

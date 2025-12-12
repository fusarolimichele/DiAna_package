# Sample Supplementary Demographic Data

A dataset containing supplementary demographic information of
individuals, including reporter codes, case IDs, and additional details.

## Usage

``` r
sample_Demo_Supp
```

## Format

A data.table with 10 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- rpsr_cod:

  Report source code (`factor`).

- caseid:

  Case ID to link the report with the public dashboard (`integer`).

- caseversion:

  Case version in case of multiple updates (`factor`).

- i_f_cod:

  Initial or follow-up version (`factor`).

- auth_num:

  Authorization number (`character`).

- e_sub:

  Electronic submission (`factor`).

- lit_ref:

  Literature reference for the case (`character`).

- rept_dt:

  Reporting date (`integer`).

- to_mfr:

  Sent to manufacturer (`character`).

- mfr_sndr:

  Manufacturer sender (`character`).

- mfr_num:

  Manufacturer id number (`character`).

- mfr_dt:

  Manufacturer date (`integer`).

- quarter:

  FAERS Quarter in which the report is stored (`factor`).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This subset of Demo_Supp provides supplementary demographic information
of reports, including details related to reporting and manufacturer
information. It is useful for understanding additional context around
adverse drug reaction reports.

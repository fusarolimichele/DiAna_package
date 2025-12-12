# Sample Demographic Data

A dataset containing demographic information of individuals with various
details such as sex, age in days, weight in kilograms, and other related
information.

## Usage

``` r
sample_Demo
```

## Format

A data frame with 15 variables:

- primaryid:

  Unique identifier for each individual (`numeric`).

- sex:

  Sex of the individual (`factor`), with levels `M` for male and `F` for
  female.

- age_in_days:

  Age of the individual in days (`numeric`).

- wt_in_kgs:

  Weight of the individual in kilograms (`numeric`).

- occr_country:

  Country where the event occurred (`factor`).

- event_dt:

  Date of the event (`integer`), in the format YYYYMMDD.

- occp_cod:

  Occupation of the reporter (`factor`), with levels `CN` for
  consumers/patients, `MD` for medical doctors, `PH` for pharmacist,
  `RN` for registered nurse, `HP` for other healthcare professional,
  `LW` for lawyer, `OT` for other occupation.

- reporter_country:

  Country of the reporter (`factor`).

- rept_cod:

  Report code (`factor`), with levels `EXP` for expedited (i.e., a
  serious and unexpected reaction which should be reported within 30
  days from the first reception by the pharmaceutical company), `PER`
  for periodic (i.e., expected non-serious event, sent by the
  pharmaceutical company to the regulatory agency on a yearly basis),
  `DIR` for directed reports (i.e., submitted directly by the reporter
  through the MedWatch form, without going through pharmaceutical
  companies).

- init_fda_dt:

  First date of reception by the FDA (`integer`), in the format
  YYYYMMDD.

- fda_dt:

  Date of reception of the last update by the FDA (`integer`), in the
  format YYYYMMDD.

- premarketing:

  Logical indicator if the case is premarketing (i.e., from clinical
  trials) (`logical`).

- literature:

  Logical indicator if the case is from literature (`logical`).

- RB_duplicates:

  Logical indicator if the case is a duplicate based on the Rule Based
  algorithm (`logical`).

- RB_duplicates_only_susp:

  Logical indicator if the case is a duplicate based on the Rule Based
  algorithm considering only suspected drugs (`logical`).

## Source

https://github.com/fusarolimichele/DiAna

## Details

This dataset is a subset of the actual Demo data (that can be downloaded
using setup_DiAna()), providing a glimpse into the structure of the
database and allowing tests and documentation.

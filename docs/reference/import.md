# import

Imports the specified FAERS relational database.

## Usage

``` r
import(
  df_name,
  quarter = FAERS_version,
  pids = NA,
  save_in_environment = TRUE,
  env = .GlobalEnv
)
```

## Arguments

- df_name:

  Name of the data file (without the ".rds" extension). It can be one of
  the following:

  - *DRUG* = Suspect and concomitant drugs (active ingredient);

  - *REAC* = Suspect reactions (MedDRA PT);

  - *DEMO* = Demographics and Reporting;

  - *DEMO_SUPP* = Demographics and Reporting;

  - *INDI* = Reasons for use;

  - *OUTC* = Outcomes;

  - *THER* = Drug regimen information;

  - *DOSES* = Dosage information;

  - *DRUG_SUPP* = Dechallenge, Rechallenge, route, form;

  - *DRUG_NAME* = Suspect and concomitant drugs (raw terms);

- quarter:

  The quarter from which to import the data. For updated analyses use
  last quarterly update, in the format *23Q1*. Defaults to the value
  assigned to FAERS_version.

- pids:

  Optional vector of primary IDs to subset the imported data. Defaults
  to the entire population.

- save_in_environment:

  is a parameter automatically used within functions to avoid that the
  imported databases are overscribed.

- env:

  The environment where the data will be assigned. Default to .GlobalEnv

## Value

A data.table containing the imported data.

## Examples

``` r
# This example requires that setup_DiAna has been run to download data
FAERS_version <- "24Q1"
if (file.exists("data/24Q1/DRUG.rds")) {
  import("DRUG")
}
```

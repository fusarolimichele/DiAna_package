# import

Imports the specified FAERS relational database.

## Usage

``` r
import(
  df_name,
  quarter = FAERS_version,
  pids = NA,
  save_in_environment = TRUE,
  env = parent.frame()
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

  Whether to also assign the table, named in title case (e.g. `Drug` for
  `"DRUG"`), in `env`. Default `TRUE`. Use `FALSE` to only return it,
  e.g. `my_drug <- import("DRUG", save_in_environment = FALSE)`.

- env:

  The environment where the table is assigned. Defaults to the
  environment `import()` is called from: your workspace when called from
  the console or a script, or the calling function's own environment
  when called inside a function.

## Value

The imported data.table (invisibly when it is also assigned).

## Examples

``` r
# This example requires that setup_DiAna has been run to download data
if (file.exists(file.path(here::here(), "data", "24Q1", "DRUG.rds"))) {
  import("DRUG", quarter = "24Q1")
}
```

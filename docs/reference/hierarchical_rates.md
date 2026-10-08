# Generate Hierarchy of events or substances

This function generates a hierarchy of reporting rates for a specified
entity and based on different MedDRA or ATC levels and writes the result
to a xlsx file.

## Usage

``` r
hierarchical_rates(
  pids_cases,
  entity = "reaction",
  file_name = paste0(project_path, "reporting_rates.xlsx"),
  drug_role = c("PS", "SS", "I", "C"),
  save_in_excel = !missing(file_name),
  temp_meddra = NULL,
  temp_atc = NULL,
  ...
)
```

## Arguments

- pids_cases:

  Vector of primary IDs identifying the sample of interest.

- entity:

  Entity investigated. It can be one of the following:

  - *reaction*;

  - *indication*;

  - *substance*.

- file_name:

  Path of the XLSX file to save the hierarchy in, if
  `save_in_excel = TRUE`. Default "reporting_rates.xlsx" in
  `project_path`.

- drug_role:

  If entity is substance, it is possible to specify the drug roles that
  should be considered

- save_in_excel:

  Whether to also save the hierarchy in an Excel file, `file_name`.
  Defaults to `TRUE` only if `file_name` is supplied.

- temp_meddra:

  MedDRA dictionary, used for the levels "hlt", "hlgt" and "soc". By
  default, `MedDRA` from your workspace if it is loaded, otherwise it is
  read with
  [`import_MedDRA()`](https://fusarolimichele.github.io/DiAna_package/reference/import_MedDRA.md).

- temp_atc:

  ATC classification, used for the levels "Class1" to "Class4". By
  default, `ATC` from your workspace if it is loaded, otherwise it is
  read with
  [`import_ATC()`](https://fusarolimichele.github.io/DiAna_package/reference/import_ATC.md).
  Only primary ATC codes are used.

- ...:

  Case tables passed on to
  [`reporting_rates()`](https://fusarolimichele.github.io/DiAna_package/reference/reporting_rates.md):
  `temp_reac`, `temp_indi` and `temp_drug`. By default, `Reac`, `Indi`
  and `Drug` from your workspace.

## Value

A data.table with the hierarchy of interest. For indications and
reactions, SOCs are ordered by occurrences and, within, HLGTs, HLTs,
PTs. For substances, the ATC hierarchy is followed.

## Examples

``` r
# The following examples require the MedDRA and the ATC to be available
pids <- sample_Demo$primaryid
if (file.exists(file.path(here::here(), "external_sources", "meddra_primary.csv"))) {
  MedDRA <- import_MedDRA()
  hierarchical_rates(pids, "reaction", temp_meddra = MedDRA, temp_reac = sample_Reac)
  hierarchical_rates(pids, "indication", temp_meddra = MedDRA, temp_indi = sample_Indi)
}
if (file.exists(file.path(here::here(), "external_sources", "ATC_DiAna.csv"))) {
  ATC <- import_ATC()
  hierarchical_rates(pids, "substance", temp_atc = ATC, temp_drug = sample_Drug)
}
```

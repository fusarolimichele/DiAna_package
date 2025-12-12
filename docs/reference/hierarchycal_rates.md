# Generate Hierarchy of events or substances

This function generates a hierarchy of reporting rates for a specified
entity and based on different MedDRA or ATC levels and writes the result
to a xlsx file.

## Usage

``` r
hierarchycal_rates(
  pids_cases,
  entity = "reaction",
  file_name = paste0(project_path, "reporting_rates.xlsx"),
  drug_role = c("PS", "SS", "I", "C")
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

  Path to save the XLSX file containing the hierarchy.

- drug_role:

  If entity is substance, it is possible to specify the drug roles that
  should be considered

## Value

An excel file with the hierarchy of interest. For indications and
reactions, SOCs are ordered by occurrences and, within, HLGTs, HLTs,
PTs. For substances, the ATC hierarchy is followed.

## Examples

``` r
# The following examples require the MedDRA and the ATC to be imported
if (file.exists("external_sources/meddra_primary")) {
  hierarchycal_rates(pids, "reaction", "reactions_rates.xlsx")
}
if (file.exists("external_sources/meddra_primary")) {
  hierarchycal_rates(pids, "indication", "indications_rates.xlsx")
}
if (file.exists("external_sources/ATC_DiAna")) {
  hierarchycal_rates(pids, "substance", "substances_rates.xlsx")
}
```

# Fix DiAna Dictionary Locally

This function updates the DiAna dictionary based on changes specified in
an Excel file. It imports necessary data, identifies records to be
fixed, and updates the dictionary accordingly.

## Usage

``` r
Fix_DiAna_dictionary_locally(
  changes_xlsx_name,
  temp_drug = NULL,
  temp_drug_name = NULL
)
```

## Arguments

- changes_xlsx_name:

  Path of the Excel file containing the changes, with the columns
  `drugname` (raw drug name) and `substance` (the active ingredient it
  should be translated to).

- temp_drug:

  Drug dataset. Defaults to `Drug` if it is in your workspace; otherwise
  it is imported for the quarter in `FAERS_version`.

- temp_drug_name:

  Drug_name dataset. Defaults to `Drug_name` if it is in your workspace;
  otherwise it is imported for the quarter in `FAERS_version`.

## Value

A data.table with the updated Drug information.

## Details

The function performs the following steps:

- Reads the changes from the specified Excel file.

- Uses the `Drug` and `Drug_name` tables, importing them if they are not
  available.

- Identifies the records in `Drug_name` that need to be fixed based on
  the changes.

- Replaces the substance of those records in the `Drug` table.

## Examples

``` r
changes <- tempfile(fileext = ".xlsx")
writexl::write_xlsx(data.frame(drugname = "humira", substance = "adalimumab"), changes)
Drug <- Fix_DiAna_dictionary_locally(changes,
  temp_drug = sample_Drug, temp_drug_name = sample_Drug_Name
)
unlink(changes)
```

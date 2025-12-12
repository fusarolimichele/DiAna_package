# Fix DiAna Dictionary Locally

This function updates the DiAna dictionary based on changes specified in
an Excel file. It imports necessary data, identifies records to be
fixed, and updates the dictionary accordingly.

## Usage

``` r
Fix_DiAna_dictionary_locally(changes_xlsx_name)
```

## Arguments

- changes_xlsx_name:

  A string specifying the name of the Excel file containing the changes.

## Value

A data.table with the updated Drug information.

## Details

The function performs the following steps:

- Reads the changes from the specified Excel file.

- Imports the necessary data tables (`DRUG_NAME` and `DRUG`) if they do
  not already exist.

- Identifies the records in `Drug_name` that need to be fixed based on
  the changes.

- Joins the changes with the identified records and updates the `Drug`
  table.

- Removes the old records and adds the updated records to the `Drug`
  table.

## Examples

``` r
# This example needs that DiAna dictionary is downloaded (using setup_DiAna),
# and that an excel file with intended changes is available
if (file.exists("changes.xlsx") & file.exists("external_source/DiAna_dictionary.csv")) {
  Drug <- Fix_DiAna_dictionary_locally("changes.xlsx")
}
```

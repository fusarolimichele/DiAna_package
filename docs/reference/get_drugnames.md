# Retrieve Drug Names from FAERS Database

This function retrieves drug names and their occurrence percentages from
the FDA Adverse Event Reporting System (FAERS) database for a specified
drug substance.

## Usage

``` r
get_drugnames(drug, temp_d = Drug, temp_d_name = Drug_name)
```

## Arguments

- drug:

  Character string representing the drug substance for which drug names
  are to be retrieved.

- temp_d:

  Drug database. Can be set to sample_Drug for testing.

- temp_d_name:

  Drug_name database. Can be set to sample_Drug_Name for testing.

## Value

A data table containing drug names and their corresponding occurrence
percentages.

## Details

The function imports data from the "DRUG" and "DRUG_NAME" tables in the
specified quarter of the FAERS database. It calculates the total number
of occurrences for each unique drug name and orders the results in
descending order based on occurrence count. The resulting data table
includes drug names and their occurrence percentages.

## See also

[`import`](https://fusarolimichele.github.io/DiAna_package/reference/import.md)

## Examples

``` r
get_drugnames("adalimumab", temp_d = sample_Drug, temp_d_name = sample_Drug_Name)
```

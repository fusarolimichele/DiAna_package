# Extract Standardised MedDRA Queries (SMQs)

This function extracts and organizes Standardised MedDRA Queries (SMQs)
from an external CSV file. The function categorizes SMQs into different
levels and provides either a "Narrow" scope or all available terms.

## Usage

``` r
extractSMQ(Narrow = TRUE)
```

## Arguments

- Narrow:

  Logical, default is `TRUE`. If `TRUE`, only the "Narrow" scope SMQs
  are returned. If `FALSE`, all SMQs are included.

## Value

A named list where each element corresponds to an SMQ group. The names
represent the SMQ category, and the values are character vectors of
Preferred Terms (PTs) associated with that SMQ.

## Details

The function reads the SMQ dictionary from an external CSV file located
at: `external_sources/smq_dictionary.csv`. Since MedDRA subscription is
required, the user must obtain the SMQ dictionary separately.
Instructions for setting up the required files are provided in the DiAna
GitHub repository: <https://github.com/fusarolimichele/DiAna>.

The function processes five hierarchical levels (`SMQ_1` to `SMQ_5`) and
assigns Preferred Terms (PTs) accordingly, filtering by "Narrow" scope
if requested.

## Note

If the required SMQ dictionary file is missing, the function stops
execution and returns an error message.

## Examples

``` r
if (FALSE) { # \dontrun{
smq_list <- extractSMQ(Narrow = TRUE)
smq_list <- extractSMQ(Narrow = FALSE)
} # }
```

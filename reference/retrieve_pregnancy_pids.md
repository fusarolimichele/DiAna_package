# Retrieve Pregnancy-Related Report Identifiers from FAERS

This function retrieves the identifiers of pregnancy-related reports
from the FDA Adverse Event Reporting System (FAERS) for a specified
quarter.

## Usage

``` r
retrieve_pregnancy_pids(quarter = FAERS_version)
```

## Arguments

- quarter:

  A character string specifying the FAERS quarter to retrieve data for.
  Default is the current FAERS version (`FAERS_version`). It can also be
  set to "sample" to use instead sample data, mainly for testing.

## Value

A list containing five elements:

- `high_specificity`:

  A vector of identifiers with high specificity for pregnancy-related
  reports.

- `medium_specificity`:

  A vector of identifiers with medium specificity for pregnancy-related
  reports.

- `low_specificity`:

  A vector of identifiers with low specificity for pregnancy-related
  reports.

- `paternal_exposure`:

  A vector of identifiers for paternal exposure-related reports.

- `flowchart`:

  An editable flowchart showing case retrieval

## Details

The function processes data from multiple FAERS tables (`DEMO`, `DRUG`,
`REAC`, `INDI`, `OUTC`, `THER`, and `DRUG_SUPP`) to identify
pregnancy-related reports based on specific indications, reactions, and
drug routes. The results are filtered to exclude reports unlikely to be
related to pregnancy (e.g., reports involving males, children, or older
adults). The algorithm is an implementation and evolution of the
original pregnancy algorithm by Sakai,ref. 10.3389/fphar.2022.1063625
\#' @references Sakai T, Mori C, Ohtsu F. Potential safety signal of
pregnancy loss with vascular endothelial growth factor inhibitor
intraocular injection: A disproportionality analysis using the Food and
Drug Administration Adverse Event Reporting System. Front Pharmacol.
2022 Nov 10;13:1063625. doi: 10.3389/fphar.2022.1063625. PMID: 36438807;
PMCID: PMC9684212.

## Examples

``` r
# This function retrieves the pregnancy FAERS from the entire database.
# therefore it requires the data to have been downloaded.
FAERS_version <- "24Q1"
if (file.exists("data/24Q1/DEMO.rds")) {
  pids_pregnancy <- retrieve_pregnancy_pids()
  pids_pregnancy$medium_specificity
}
```

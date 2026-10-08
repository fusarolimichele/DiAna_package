# Retrieve Pregnancy-Related Report Identifiers from FAERS (deprecated)

**Deprecated.** It will be removed in the next release of DiAna. Use the
PVgravID package instead, which implements the pregnancy-identification
algorithms and is maintained by the Uppsala Monitoring Centre. PVgravID
is not on CRAN; install it with
`remotes::install_github("Uppsala-Monitoring-Centre/PVgravID")`. The
article "Pregnancy analyses with PVgravID"
(<https://fusarolimichele.github.io/DiAna_package/articles/PVgravID_extension.html>)
shows how to use it with DiAna data.

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

## References

Sakai T, Mori C, Ohtsu F. Potential safety signal of pregnancy loss with
vascular endothelial growth factor inhibitor intraocular injection: A
disproportionality analysis using the Food and Drug Administration
Adverse Event Reporting System. Front Pharmacol. 2022 Nov 10;13:1063625.
doi: 10.3389/fphar.2022.1063625. PMID: 36438807; PMCID: PMC9684212.

## See also

The PVgravID package:
<https://uppsala-monitoring-centre.github.io/PVgravID/>

## Examples

``` r
# Deprecated: use the PVgravID package instead.
# On the sample data shipped with DiAna
pids_pregnancy <- retrieve_pregnancy_pids(quarter = "sample")
#> Warning: retrieve_pregnancy_pids() is deprecated and will be removed in the next release of DiAna. Use the PVgravID package instead: remotes::install_github("Uppsala-Monitoring-Centre/PVgravID"). See https://fusarolimichele.github.io/DiAna_package/articles/PVgravID_extension.html
pids_pregnancy$medium_specificity
#> [1] 209984413  90142505 122688521 141551261 172405551 186233281 196446181
#> [8] 214536961 164548722

# On the entire database, which requires the data downloaded with setup_DiAna()
if (file.exists(file.path(here::here(), "data", "24Q1", "DEMO.rds"))) {
  pids_pregnancy <- retrieve_pregnancy_pids(quarter = "24Q1")
}
```

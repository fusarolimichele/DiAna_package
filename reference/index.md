# Package index

## Setup

Functions to download cleaned FAERS data from the internet and snippet
to automatically structure a script.

- [`setup_DiAna()`](https://fusarolimichele.github.io/DiAna_package/reference/setup_DiAna.md)
  : Set Up DiAna Environment
- [`snippets_install_github()`](https://fusarolimichele.github.io/DiAna_package/reference/snippets_install_github.md)
  : Install RStudio Snippets from GitHub Repository

## Datasets

Datasets made available with the DiAna package.

### Sample datasets with documentation

- [`sample_Demo`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Demo.md)
  : Sample Demographic Data
- [`sample_Demo_Supp`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Demo_Supp.md)
  : Sample Supplementary Demographic Data
- [`sample_Doses`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Doses.md)
  : Sample Data on Drug Doses
- [`sample_Drug`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Drug.md)
  : Sample Data on Drug Administration
- [`sample_Drug_Name`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Drug_Name.md)
  : Sample Data on Drug Names before standardization
- [`sample_Drug_Supp`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Drug_Supp.md)
  : Sample Supplementary Drug Information
- [`sample_Indi`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Indi.md)
  : Sample dataset containing indications for using reported drugs.
- [`sample_Outc`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Outc.md)
  : Sample Data on Individual Outcomes
- [`sample_Reac`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Reac.md)
  : Sample dataset containing events (suspected adverse drug reactions)
  and related information.
- [`sample_Ther`](https://fusarolimichele.github.io/DiAna_package/reference/sample_Ther.md)
  : Sample Data on Therapy Details

### Importing fuctions for the full downloaded FAERS data

- [`import()`](https://fusarolimichele.github.io/DiAna_package/reference/import.md)
  : import
- [`import_ATC()`](https://fusarolimichele.github.io/DiAna_package/reference/import_ATC.md)
  : Import ATC classification
- [`import_MedDRA()`](https://fusarolimichele.github.io/DiAna_package/reference/import_MedDRA.md)
  : Import MedDRA Data
- [`extractSMQ()`](https://fusarolimichele.github.io/DiAna_package/reference/extractSMQ.md)
  : Extract Standardised MedDRA Queries (SMQs)

### Additional datasets provided for internal use by functions

- [`country_dictionary`](https://fusarolimichele.github.io/DiAna_package/reference/country_dictionary.md)
  : Country Dictionary Dataset

## Case retrieval

Functions to retrieve cases or specific subpopulations.

### Retrieve cases for manual inspection

- [`retrieve()`](https://fusarolimichele.github.io/DiAna_package/reference/retrieve.md)
  : Retrieve data for specific primaryids

### Tailor drug definition

- [`get_drugnames()`](https://fusarolimichele.github.io/DiAna_package/reference/get_drugnames.md)
  : Retrieve Drug Names from FAERS Database
- [`Fix_DiAna_dictionary_locally()`](https://fusarolimichele.github.io/DiAna_package/reference/Fix_DiAna_dictionary_locally.md)
  : Fix DiAna Dictionary Locally

### Identify specific subpopulations

- [`retrieve_pregnancy_pids()`](https://fusarolimichele.github.io/DiAna_package/reference/retrieve_pregnancy_pids.md)
  : Retrieve Pregnancy-Related Report Identifiers from FAERS

## Descriptive functions

Functions to perform descriptive analyses.

- [`descriptive()`](https://fusarolimichele.github.io/DiAna_package/reference/descriptive.md)
  : Generate Descriptive Statistics for a Sample
- [`new_descriptive()`](https://fusarolimichele.github.io/DiAna_package/reference/new_descriptive.md)
  : Generate Descriptive Statistics for a Sample
- [`hierarchycal_rates()`](https://fusarolimichele.github.io/DiAna_package/reference/hierarchycal_rates.md)
  : Generate Hierarchy of events or substances
- [`reporting_rates()`](https://fusarolimichele.github.io/DiAna_package/reference/reporting_rates.md)
  : Reporting rates of events or substances
- [`render_tto()`](https://fusarolimichele.github.io/DiAna_package/reference/render_tto.md)
  : TTO Render Forest Plot

## Disproportionality functions

Functions to perform disproportionality analyses.

- [`disproportionality_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_analysis.md)
  : Perform Disproportionality Analysis
- [`disproportionality_comparison()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_comparison.md)
  : Disproportionality Analysis for Drug-Event Combinations
- [`disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/disproportionality_trend.md)
  : Disproportionality Time Trend for a Drug-Event Combination
- [`format_input_disproportionality()`](https://fusarolimichele.github.io/DiAna_package/reference/format_input_disproportionality.md)
  : Format Input for Disproportionality Analysis
- [`tailor_disproportionality_threshold()`](https://fusarolimichele.github.io/DiAna_package/reference/tailor_disproportionality_threshold.md)
  : Tailor Disproportionality Threshold
- [`plot_disproportionality_trend()`](https://fusarolimichele.github.io/DiAna_package/reference/plot_disproportionality_trend.md)
  : Plot Disproportionality Trend
- [`render_forest()`](https://fusarolimichele.github.io/DiAna_package/reference/render_forest.md)
  : Render Forest Plot
- [`render_forest_table()`](https://fusarolimichele.github.io/DiAna_package/reference/render_forest_table.md)
  : Render a Forest Plot Table from Disproportionality Data

## Advanced analyses

Functions to perform advanced analyses, including time to onset analysis
and network analysis.

### Time to onset analyses

- [`time_to_onset_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/time_to_onset_analysis.md)
  : Perform time-to-onset analysis for drug-event associations
- [`plot_KS()`](https://fusarolimichele.github.io/DiAna_package/reference/plot_KS.md)
  : Plot Kolmogorov-Smirnov (KS) plot

### Network Analysis

- [`network_analysis()`](https://fusarolimichele.github.io/DiAna_package/reference/network_analysis.md)
  : Perform Network Analysis and Visualization

## DiAna specifics

Functions to retrieve DiAna reference and information about the used
quarter.

- [`DiAna_reference()`](https://fusarolimichele.github.io/DiAna_package/reference/DiAna_reference.md)
  : Get DiAna reference
- [`FAERS_quarter_specifics()`](https://fusarolimichele.github.io/DiAna_package/reference/FAERS_quarter_specifics.md)
  : Get specifics of dictionaries used in database version

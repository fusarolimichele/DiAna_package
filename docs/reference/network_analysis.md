# Perform Network Analysis and Visualization

This function performs network analysis on the provided data and
generates a visualization of the network. It uses IsingFit to model the
network structure, clusters nodes using Louvain method, and visualizes
the resulting network graph.

## Usage

``` r
network_analysis(
  pids,
  entity = "reaction",
  remove_singlet = TRUE,
  remove_negative_edges = TRUE,
  file_name = paste0(project_path, "network.tiff"),
  width = 1500,
  height = 1500,
  labs_size = 1,
  min_frequency_term = 0.01,
  restriction = "none",
  temp_reac = Reac,
  temp_indi = Indi,
  temp_drug = Drug,
  save_plot = !missing(file_name)
)
```

## Arguments

- pids:

  Numeric vector of unique identifiers on which the network analysis
  should be performed.

- entity:

  Character specifying the type of entity to analyze ("reaction",
  "indication", or "substance").

- remove_singlet:

  Logical indicating whether to remove singleton nodes (nodes with no
  edges). Default is TRUE.

- remove_negative_edges:

  Logical indicating whether to remove edges with negative weights.
  Default is TRUE.

- file_name:

  Character string specifying the file name (including path) to save the
  network visualization, if `save_plot = TRUE`. Default is
  "network.tiff" in `project_path`.

- width:

  Numeric specifying the width of the saved image in pixels. Default is
  1500.

- height:

  Numeric specifying the height of the saved image in pixels. Default is
  1500.

- labs_size:

  Size of labels in network visualization. Default is 1. It can be
  changed if visualization is not good.

- min_frequency_term:

  Frequency threshold for a term in the dataset to be included in the
  analysis. Default to 0.01

- restriction:

  Restriction performed in the analysis. Default is none. It could be
  set to 'suspects' if entity is 'substance' to restrict the analysis to
  primary and secondary suspects

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- temp_indi:

  Indi dataset. Can be set to sample_Indi for testing

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- save_plot:

  Whether the plot should also be saved as a TIFF file, `file_name`.
  Defaults to `TRUE` only if `file_name` is supplied.

## Value

The network, as an igraph object, which can be drawn with
[`plot()`](https://rdrr.io/r/graphics/plot.default.html). If
`save_plot = TRUE`, the visualization is also saved as a TIFF file.

## References

Fusaroli M, Raschi E, Gatti M, De Ponti F, Poluzzi E. Development of a
Network-Based Signal Detection Tool: The COVID-19 Adversome in the FDA
Adverse Event Reporting System. Front Pharmacol. 2021 Dec 8;12:740707.
doi: 10.3389/fphar.2021.740707. PMID: 34955821; PMCID: PMC8694570.

Fusaroli, M., Polizzi, S., Menestrina, L. et al. Unveiling the Burden of
Drug-Induced Impulsivity: A Network Analysis of the FDA Adverse Event
Reporting System. Drug Saf (2024).
https://doi.org/10.1007/s40264-024-01471-z

## Examples

``` r
# Perform network analysis for reactions with specified pids
net_plot <- network_analysis(
  pids = sample_Demo$primaryid,
  entity = "reaction", temp_reac = sample_Reac,
  save_plot = FALSE
)
plot(net_plot)

```

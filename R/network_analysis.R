#' Perform Network Analysis and Visualization
#'
#' This function performs network analysis on the provided data and generates a visualization of the network. It uses IsingFit to model the network structure, clusters nodes using Louvain method, and visualizes the resulting network graph.
#'
#' @param pids Numeric vector of unique identifiers for data import.
#' @param entity Character specifying the type of entity to analyze ("reaction", "indication", or "substance").
#' @param remove_singlet Logical indicating whether to remove singleton nodes (nodes with no edges). Default is TRUE.
#' @param remove_negative_edges Logical indicating whether to remove edges with negative weights. Default is TRUE.
#' @param file_name Character string specifying the file name (including path) to save the network visualization. Default is "network.tiff".
#' @param width Numeric specifying the width of the saved image in pixels. Default is 1500.
#' @param height Numeric specifying the height of the saved image in pixels. Default is 1500.
#'
#' @return NULL (invisibly). Saves a network visualization as a TIFF file.
#'
#' @importFrom data.table .N
#' @importFrom igraph graph.adjacency delete.vertices delete.edges degree set_vertex_attr
#' @importFrom IsingFit IsingFit
#' @importFrom tidyr pivot_wider
#' @importFrom ggplot2 labs
#' @importFrom gridExtra grid.arrange
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' # Perform network analysis for reactions with specified pids
#' network_analysis(pids = c(1, 2, 3), entity = "reaction")
#' }
#'
#' @references
#' Fusaroli M, Raschi E, Gatti M, De Ponti F, Poluzzi E. Development of a Network-Based Signal Detection Tool: The COVID-19 Adversome in the FDA Adverse Event Reporting System. Front Pharmacol. 2021 Dec 8;12:740707. doi: 10.3389/fphar.2021.740707. PMID: 34955821; PMCID: PMC8694570.
#'
#' Fusaroli M, Polizzi S, Menestrina L, Giunchi V, Pellegrini L, Raschi E, et al. Unveiling the Hidden Toll of Drug-Induced Impulsivity: A Network Analysis of the FDA Adverse Event Reporting System. 2023; : 2023.11.17.23298635. [Cited 2023 Nov 29] Available from https://www.medrxiv.org/content/10.1101/2023.11.17.23298635v1
#'
#' @export
network_analysis <- function(pids, entity = "reaction", remove_singlet = TRUE,
                             remove_negative_edges = TRUE,
                             file_name = paste0(project_path, "network.tiff"), width = 1500, height = 1500) {
  if (entity == "reaction") {
    df <- import("REAC", pids = pids)[, .(primaryid, pt)]
  } else if (entity == "indication") {
    df <- import("INDI", pids = pids)
  } else if (entity == "substance") {
    df <- import("DRUG", pids = pids)[, .(primaryid, substance)]
  }
  df <- distinct(df)
  binary_data <- df
  binary_data$value <- 1
  if(entity=="reaction"){
    binary_data <- binary_data %>% pivot_wider(
      names_from = pt,
      values_from = value
    )
  } else if(entity=="indication"){
    binary_data <- binary_data %>% pivot_wider(
      names_from = indi_pt,
      values_from = value
    )
  } else if(entity=="substance"){
    binary_data <- binary_data %>% pivot_wider(
      names_from = substance,
      values_from = value
    )
  }
  row_names <- binary_data$primaryid
  binary_data <- binary_data %>%
    select(-primaryid) %>%
    as.matrix()
  rownames(binary_data) <- row_names
  binary_data[is.na(binary_data[, ])] <- 0
  g1 <- IsingFit::IsingFit(binary_data)
  G_igraph <- igraph::graph.adjacency(g1$weiadj, mode = "undirected", weighted = TRUE)
  if (remove_singlet) {
    G_igraph <- igraph::delete.vertices(simplify(G_igraph), igraph::degree(G_igraph) == 0)
  }
  if (remove_negative_edges) {
    G_igraph <- igraph::delete.edges(G_igraph, which(E(G_igraph)$weight < 0))
  }
  L0 <- layout_nicely(G_igraph)
  comm_lv <- cluster_louvain(G_igraph)
  t <- as.numeric(names(table(membership(comm_lv))[table(membership(comm_lv)) == 1]))
  cols <- comm_lv$membership
  cols[cols %in% t] <- 100
  G_igraph <- set_vertex_attr(G_igraph, "color", value = cols)
  G_igraph <- set_vertex_attr(G_igraph, "group", value = factor(cols))
  labs1 <- df[, .N, by = "pt"][order(-N)][, .(s = pt, s2 = N)]
  labs <- data.table(s = V(G_igraph)$name)
  labs <- left_join(labs, labs1)
  G_igraph <- set_vertex_attr(G_igraph, "size", value = log(labs$s2))
  G_igraph <- set_vertex_attr(G_igraph, "label", value = labs$s)

  tiff(file_name, width = width, height = height, res = 300)
  plot(comm_lv, G_igraph,
    layout = L0, label = labs$s, vertex.label.dist = .4, # Distance between the label and the vertex
    vertex.label.degree = pi / 2
  )
  dev.off()
}

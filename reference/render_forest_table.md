# Render a Forest Plot Table from Disproportionality Data

This function takes a data frame containing disproportionality analysis
results and generates a forest plot table using the `forestplot`
package. It highlights results with lower confidence intervals greater
than zero in red.

## Usage

``` r
render_forest_table(disproportionality_df)
```

## Arguments

- disproportionality_df:

  A `data.table` containing the following columns:

  - `nested`: Type of analysis (e.g., "Crude", "Adjusted")

  - `D_E`: Observed count

  - `expected`: Expected count

  - `IC_median`: Median Information Component

  - `IC_lower`: Lower bound of the 95% confidence interval

  - `IC_upper`: Upper bound of the 95% confidence interval

## Value

A `forestplot` object representing the forest plot table.

## Details

The function:

- Formats the input data for display

- Highlights rows with significant IC values (lower CI \> 0) in red

- Adds horizontal lines and zebra striping for readability

- Sets custom x-axis ticks and labels

## Examples

``` r
if (FALSE) { # \dontrun{
library(data.table)
df <- data.table(
  nested = c("Crude", "Adjusted"),
  D_E = c(10, 8),
  expected = c(5.5, 6.2),
  IC_median = c(1.2, 0.8),
  IC_lower = c(0.5, -0.2),
  IC_upper = c(1.9, 1.3)
)
render_forest_table(df)
} # }
```

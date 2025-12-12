# Compute Fisher's Exact Test with Simulated p-values

This function performs Fisher's Exact Test with simulated p-values for
association between two categorical variables.

## Usage

``` r
fisher.test.simulate.p.values(data, variable, by, ...)
```

## Arguments

- data:

  A data frame containing the variables of interest.

- variable:

  The name of the first categorical variable.

- by:

  The name of the second categorical variable.

- ...:

  Additional arguments to be passed to the
  [`fisher.test`](https://rdrr.io/r/stats/fisher.test.html) function.

## Value

A list containing the following elements:

- p:

  The simulated p-value for the Fisher's Exact Test.

- test:

  The name of the test method, which is "Fisher's Exact Test with
  Simulation".

## See also

[`fisher.test`](https://rdrr.io/r/stats/fisher.test.html) for more
information on Fisher's Exact Test.

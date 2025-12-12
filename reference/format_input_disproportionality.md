# Format Input for Disproportionality Analysis

This function formats the input of drug and reac selected for
disproportionality analysis. It ensures the input is in the correct list
format and processes it to meet specific structural requirements,
allowing the researcher for a greater freedom in calling the function.

## Usage

``` r
format_input_disproportionality(input)
```

## Arguments

- input:

  A list or an object that can be converted to a list (specifically,
  drug_selected and reac_selected).

## Value

A formatted list of drugs or events suitable for disproportionality
analysis

## Examples

``` r
input <- format_input_disproportionality(c("TGA" = list(
  "aripiprazole",
  "brexpiprazole",
  "cariprazine"
)))
```

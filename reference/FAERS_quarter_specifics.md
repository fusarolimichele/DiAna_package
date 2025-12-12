# Get specifics of dictionaries used in database version

This function provides specifics on dictionaries used for cleaning the
specified database version

## Usage

``` r
FAERS_quarter_specifics(quarter = FAERS_version, print = TRUE)
```

## Arguments

- quarter:

  The quarter for which specifics are needed. Default to FAERS_version.

- print:

  Logical, should the output be printed? Default to TRUE.

## Value

Specifics

## Examples

``` r
FAERS_quarter_specifics("24Q1")
#> [1] "The DiAna dictionary used to convert drugnames to substances is 24Q1"                                                                                                                                                                                                                                                             
#> [2] "If a reference is needed use: Fusaroli M, Giunchi V, Battini V, Puligheddu S, Khouri C, Carnovale C, Raschi E, Poluzzi E. Enhancing Transparency in Defining Studied Drugs: The Open-Source Living DiAna Dictionary for Standardizing Drug Names in the FAERS. Drug Saf. 2024 Mar;47(3):271-284. doi: 10.1007/s40264-023-01391-4."
#> [3] ""                                                                                                                                                                                                                                                                                                                                 
#> [4] "Events are coded according to MedDRA (the international Medical Dictionary for Regulatory Activities terminology developed under the auspices of the International Council for Harmonisation of Technical Requirements for Pharmaceuticals for Human Use (ICH), version 26.1)"                                                    
```

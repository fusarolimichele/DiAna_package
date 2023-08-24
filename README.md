
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DiAna

<!-- badges: start -->
<!-- badges: end -->

The goal of DiAna is to enchance the transparency,
flexibility,replicability, and tool exchange capabilities within the
domain of pharmacovigilance studies. This specialized R package has been
meticulously crafted to facilitate the intricate process of
disproportionality analysis on the FDA Adverse Event Reporting System
(FAERS) data. DiAna empowers researchers and pharmacovigilance
professionals with a comprehensive toolkit to conduct rigorous and
transparent analyses. By providing customizable functions and clear
documentation, the package ensures that each step of the analysis is
fully understood and reproducible. Pharmacovigilance studies often
require tailored approaches due to the diverse nature of adverse event
data. The package offers a range of versatile tools that can be
seamlessly adapted to different study designs, data structures, and
analytical goals. Researchers can effortlessly modify parameters and
methods to suit their specific requirements. Collaboration and
knowledge-sharing are fundamental to advancing pharmacovigilance
research. DiAna plays a pivotal role in enabling the exchange of tools
and methodologies among researchers. Its modular design encourages the
development and integration of new analysis techniques, fostering a
dynamic environment for innovation.

## Installation

You can install the development version of DiAna from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("fusarolimichele/DiAna_package")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(DiAna)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.

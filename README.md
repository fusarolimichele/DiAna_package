
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DiAna

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
dynamic environment for innovation. DiAna simplifies the process of
importing cleaned FAERS data, retrieving cases of interest, conducting
descriptive analysis, and performing disproportionality analysis.
Whether you’re a novice or an expert in pharmacovigilance, DiAna is
designed to make your analyses easy and efficient.

## Prerequisites: Installing R and R Studio

Before you can start using DiAna, you need to have R and R Studio
installed on your system. If you haven’t installed them yet, follow
these simple steps:

1.  Installing R Visit the official R project website
    (<https://cran.r-project.org>) and download the appropriate version
    of R for your operating system (Windows, macOS, or Linux). Run the
    installer and follow the instructions to complete the installation.
    R provides a powerful and flexible environment for statistical
    computing and graphics, forming the foundation for your data
    analysis with DiAna.

2.  Installing R Studio R Studio is an integrated development
    environment (IDE) for R that makes your R programming easier and
    more efficient. Once R is installed, go to the R Studio website
    (<https://posit.co/download/rstudio-desktop/>) and download the free
    version of R Studio Desktop. Install R Studio by following the
    installation instructions for your operating system.

With R and R Studio installed, you have a comprehensive and
user-friendly environment ready for conducting pharmacovigilance
analyses using DiAna.

## Setting Up Your DiAna Project

For an organized and efficient workflow, we recommend creating a
dedicated project for your DiAna analyses. Follow these steps to set up
your DiAna project in R Studio:

1.  Open R Studio: Start by opening R Studio on your computer. If you’ve
    just installed R Studio, you can find it in your applications or
    programs menu.

2.  Create a New Project: In R Studio, click on File in the upper left
    corner, then select New Project. Choose New Directory and then New
    Project. Name your project (e.g., “DiAna”) and specify a location on
    your Desktop or any preferred directory.

3.  Install the DiAna package: Begin by installing the DiAna package
    from [GitHub](https://github.com/) writing and running the following
    lines in the console:

``` r
install.packages("devtools")
devtools::install_github("fusarolimichele/DiAna_package")
```

It may be useful to run this command from time to time to download the
latest update to the package (e.g., bugs solved, new or improved
functions)

4.  Setup the DiAna project: The first time we use DiAna, we have to set
    up the folder where the data will be stored together with the
    results of the analyses. This command will require a good internet
    connection. The better your internet connection, the faster the
    download. It usually takes between a few minutes and 20 minutes. On
    the console, we run the two rows below (note that rows preceded by a
    \# are comments and not commands):

``` r
library(DiAna)
setup_DiAna(quarter = "24Q1")
# input yes when asked to download the FAERS
```

With library DiAna we have imported the DiAna package (i.e., the toolbox
with all the functions that we will use in our analyses). With
setup_DiAna(quarter=“24Q1”) we are automaticatilly setting up the
project: it will create a folder to store cleaned FAERS data, that will
be downloaded from an OSF repository (in particular we are downloading
the entire FAERS database, including all the quarters up to the 24Q1).
The entire cleaning process is made transparent on the github
(<https://github.com/fusarolimichele/DiAna>). It will also create a
folder for external sources and a folder to store projects. In the
external sources, it will also download the DiAna dictionary used to
translate free text drug names into active ingredients, a linkage to the
ATC code, and other useful data sources.

Some external sources are not available for download because they
require subscription (e.g., MedDRA).

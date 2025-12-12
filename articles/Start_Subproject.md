# Start Subproject

This tutorial will show you how to initiate a subproject folder, setup
the FAERS version, import and access the FAERS data and its
documentation.

## Requisites

This tutorial requires that you have first:

1.  installed R and R Studio,

2.  installed the DiAna package,

3.  and set up your project folder.

Otherwise get back to the ReadMe and follow the instructions.

## Starting a subproject

With DiAna the main project, we now want to create a subproject specific
for this tutorial. The first thing we do is open a new R script (the
white paper with the green and white cross on the top left corner of
rstudio) and insert some details on the project. As specified before,
every time we use a \# we are inserting a comment. Comments are
extremely useful to document and explain our project, but are not run
and do not affect the results.

``` r
# Information -----------------------------------------------------------------
## Project title --------------------------------------------------------------
### Setting up a DiAna subproject

## Data -----------------------------------------------------------------------
### FDA Adverse Event Reporting System Quarterly Data

## Authors --------------------------------------------------------------------
### Michele Fusaroli

## Version --------------------------------------------------------------------
### Set up: 2024-07-23
### Last update: 2024-07-23
```

You can also see that we can create a kind of skeleton/structure of our
script both:

- using one \# for first level headings, \## for second level headings,
  and so on…

- adding the dashes after the heading to point to R studio that this is
  actually a heading.

The nice thing of starting to work in such a organized way is that you
make the script readable for other researchers and for yourself in the
future. It also forces you to be aware of your entire study design at
each moment, reducing the possibility of creating overlapping chunks of
codes and making errors. Finally, it allows you to easily navigate the
script using the window pane you can access clicking on the writing in
the left corner of the script.

After we have included the information we deem necessary to document our
script, we upload the DiAna package.

``` r
# Set up ----------------------------------------------------------------------
## upload DiAna ---------------------------------------------------------------
library(DiAna)
#> Loading required package: data.table
#> Loading required package: ggplot2
```

### **Setting Up Your DiAna Subproject**

In this section, we guide you through setting up a subproject within
your DiAna analysis environment. The following R code chunk creates a
new directory named “tutorial” within the “projects” folder of your
DiAna folder. The
**[`here::here()`](https://here.r-lib.org/reference/here.html)**
function helps locate the current DiAna package directory, and the
project_path variable is defined to point to the “tutorial” folder for
storing the output. If you want to give a better name to the project
just change the string assinged to the variable project_name.

``` r
## Project_path ---------------------------------------------------------------
DiAna_path <- here::here()
project_name <- "tutorial"
project_path <- paste0(DiAna_path, "/projects/", project_name)
if (!file.exists(project_path)) {
  dir.create(project_path)
}
project_path <- paste0(project_path, "/")
```

By running this code, you establish a structured subproject environment.
The “tutorial” folder will contain the necessary files and
configurations for your subproject, ensuring a seamless and organized
analysis experience.

Finally, we save the script in the subproject folder, using the blue
floppy icon above the script and finding the right directory. We suggest
to give the script the same name of the folder.

### **Input data and packages**

In the DiAna package, seamless data import is a crucial aspect of
empowering pharmacovigilance analyses. We first set the FAERS version,
that is the last quarter we want to be included in the analysis.

``` r
## FAERS_version --------------------------------------------------------------
FAERS_version <- "24Q1"
```

Note that you have to first download the data using setup_DiAna,
following the information of the ReadMe, otherwise it will not find in
the data folder the data you want to import. This structure will help
you, if needed, to update your results to a new quarter just changing
the quarter here and rerunning the whole script.

The second code chunk utilizes the import() function to load essential
datasets from the FDA Adverse Event Reporting System (FAERS). It uses
the FAERS_version we provided, and if you did not set it, you will see
an error remembering you to set the FAERS_version.

``` r
## Import data ----------------------------------------------------------------
import("DRUG")
import("REAC")
import("DEMO")
import("INDI")
```

By importing datasets like “DRUG”, “REAC”, “DEMO”, and “INDI” DiAna
equips users with comprehensive information about drugs, adverse
reactions, patient demographics, and indications. The act of importing
prints also a sample of the data in console. Furthermore, note that a
sample of each FAERS dataset (including also Outc, Ther, Doses,
Demo_Supp, Drug_Supp, and Drug_Name) with information about 1000 random
reports is available with the package and can be accessed calling
“sample\_” and the name of the dataset, as shown below (you may run
this, but you may not include it in your script):

``` r
sample_Demo
#>       primaryid    sex age_in_days wt_in_kgs             occr_country event_dt
#>           <num> <fctr>       <num>     <num>                   <fctr>    <int>
#>    1:   4315260      M          NA        NA                     <NA>       NA
#>    2:   4329569      F          NA        NA                     <NA>       NA
#>    3:   4447614      F          NA        NA                     <NA>       NA
#>    4:   4450462      M       21900        NA                     <NA> 20031203
#>    5:   4458274      F       16790        NA                     <NA>       NA
#>   ---                                                                         
#>  996: 221121011      F          NA        NA United States of America       NA
#>  997: 221339931   <NA>          NA        NA United States of America       NA
#>  998: 221399731      F       29200        NA United States of America       NA
#>  999: 220166883      M       18250        92 United States of America 20230214
#> 1000: 220784242      F       16790        NA United States of America 20230222
#>       occp_cod         reporter_country rept_cod init_fda_dt   fda_dt
#>         <fctr>                   <fctr>   <fctr>       <int>    <int>
#>    1:       OT                     <NA>      EXP          NA 20040309
#>    2:       CN                     <NA>      PER          NA 20040319
#>    3:       CN                     <NA>      PER          NA 20040823
#>    4:     <NA>                     <NA>      EXP          NA 20040914
#>    5:       CN                     <NA>      PER          NA 20040917
#>   ---                                                                
#>  996:       CN United States of America      PER    20230318 20230318
#>  997:       CN United States of America      PER    20230324 20230324
#>  998:       HP United States of America      EXP    20230327 20230327
#>  999:       CN United States of America      PER    20230221 20230328
#> 1000:       MD United States of America      PER    20230309 20230330
#>       premarketing literature RB_duplicates RB_duplicates_only_susp
#>             <lgcl>     <lgcl>        <lgcl>                  <lgcl>
#>    1:        FALSE      FALSE         FALSE                    TRUE
#>    2:        FALSE      FALSE          TRUE                    TRUE
#>    3:        FALSE      FALSE         FALSE                   FALSE
#>    4:        FALSE      FALSE         FALSE                   FALSE
#>    5:        FALSE      FALSE         FALSE                   FALSE
#>   ---                                                              
#>  996:        FALSE      FALSE         FALSE                   FALSE
#>  997:        FALSE      FALSE         FALSE                   FALSE
#>  998:        FALSE       TRUE         FALSE                   FALSE
#>  999:        FALSE      FALSE         FALSE                   FALSE
#> 1000:        FALSE      FALSE         FALSE                   FALSE
```

Notably, you can get information about all the information stored in the
FAERS database just running the name of the dataset you are interested
in preceded by a question mark (again, you may run this but you may not
include it in your script). The help window of R studio, usually on the
lower right corner, will include the documentation.

``` r
?sample_Demo
```

Moreover, DiAna offers functionality to import data related to the
Anatomical Therapeutic Chemical (ATC) classification linked to the
active ingredients as translated by the DiAna dictionary. This ATC file
is a crucial component for grouping drugs based on their therapeutic
use.

DiAna does not make available the Medical Dictionary for Regulatory
Activities (MedDRA, a hierarchical dictionary used to code the events),
which is only upon subscription, but makes available an import_MedDRA
function. If you have access to MedDRA, you can follow the instructions
on the DiAna GitHub repository to create the MedDRA file for the
import_MedDRA function.

``` r
import_ATC()
```

### **Summing up**

This vignette showed you how to initiate a subproject folder, setup the
FAERS version, import and access the FAERS data and its documentation.
It is plausible that you will have to repeat this script every time you
start a new FAERS project. To promote clarity and standardization, and
at the same time gratify laziness, there is a way to include this entire
script automatically instead than manually. It is called snippet: a
chunk of code that can be included in a script just by writing in the
script a short snippet command.

You can get a set of useful snippets running the DiAna command
snippets_install_github() on your console, when you have an internet
connection. Note that this way it is extremely easy to share scripts of
FAERS studies.

After running the function, we can just open a new R script and write on
it “new_FAERS_project” (which R Studio says us it is a snippet), and it
will autocompile the script with something similar to the following
chunk. Then we just need to include the details of our specific study.

``` r
# Information -----------------------------------------------------------------
## Project title --------------------------------------------------------------
### TITLE

## Data -----------------------------------------------------------------------
### FDA Adverse Event Reporting System Quarterly Data

## Authors --------------------------------------------------------------------
### NAME SURNAME

## Version --------------------------------------------------------------------
### Set up: yyyy-mm-dd
### Last update: yyyy-mm-dd
### DiAna version: X.X.X

# Set up ----------------------------------------------------------------------
## upload DiAna ---------------------------------------------------------------
library(DiAna)

## Project_path ---------------------------------------------------------------
DiAna_path <- here::here()
project_name <- "project_name"
project_path <- paste0(DiAna_path, "/projects/", project_name)
if (!file.exists(project_path)) {
  dir.create(project_path)
}
project_path <- paste0(project_path, "/")

## FAERS_version --------------------------------------------------------------

FAERS_version <- "24Q1"

## Import data ----------------------------------------------------------------
import("DRUG")
import("REAC")
import("DEMO")
import("DEMO_SUPP")
import("INDI")
import("DOSES")
import("THER")
import("OUTC")
import("DRUG_SUPP")
import("DRUG_NAME")
import_MedDRA()
import_ATC()

## Input files ---------------------------------------------------------------

## Output files --------------------------------------------------------------
```

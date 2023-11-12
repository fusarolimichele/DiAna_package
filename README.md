Basic_usage_of_DiAna
================

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

# DiAna: Disproportionality Analysis for Pharmacovigilance

## Introduction

Welcome to DiAna, your go-to R package for performing disproportionality
analysis on the FDA Adverse Event Reporting System (FAERS). DiAna
simplifies the process of importing cleaned FAERS data, retrieving cases
of interest, conducting descriptive analysis, and performing
disproportionality analysis. Whether you’re a novice or an expert in
pharmacovigilance, DiAna is designed to make your analyses easy and
efficient.

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
setup_DiAna(quarter = "23Q1")
# input yes when asked to download the FAERS
```

With library DiAna we have imported the DiAna package (i.e., the toolbox
with all the functions that we will use in our analyses). With
setup_DiAna(quarter=“23Q1”) we are automaticatilly setting up the
project: it will create a folder to store cleaned FAERS data, that will
be downloaded from an OSF repository (in particular we are downloading
the FAERS updated to the 23Q1 quarter). The entire cleaning process is
made transparent on the github
(<https://github.com/fusarolimichele/DiAna>). It will also create a
folder for external sources and a folder to store projects. In the
external sources, it will also download the DiAna dictionary used to
translate free text drug names into active ingredients, a linkage to the
ATC code, and other useful data sources.

![](images/DiAna%20folder.png)

As you can see some external sources are not available for download
because they require subscription (e.g., MedDRA).

## Getting Started

Now that you have R and R Studio installed, you have installed the DiAna
package, and you have set up your project, you are all set to begin your
journey with DiAna.

### Starting a subproject

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
### Tutorial on the Basic usage of DiAna
## Data -----------------------------------------------------------------------
### FDA Adverse Event Reporting System Quarterly Data up to 23Q1
## Authors --------------------------------------------------------------------
### Michele Fusaroli
## Version --------------------------------------------------------------------
### Set up: 2023-10-08### Last update: 2023-10-08
```

### **Setting Up Your DiAna Subproject**

In this section, we guide you through setting up a subproject within
your DiAna analysis environment. The following R code snippet creates a
new directory named “tutorial” within the “projects” folder of your
DiAna package. It specifies the version of the FAERS dataset to be used
(in this case, “23Q1”). The **`here::here()`** function helps locate the
current DiAna package directory, and the project_path variable is
defined to point to the “tutorial” folder within your DiAna package.

``` r
# Set up ----------------------------------------------------------------------
dir.create(paste0(here::here(), "/projects/tutorial"), recursive = TRUE)
#> Warning in dir.create(paste0(here::here(), "/projects/tutorial"), recursive =
#> TRUE): '/Users/michele.fusaroli/Desktop/DiAna_package/DiAna/projects/tutorial'
#> already exists
FAERS_version <- "23Q1"
DiAna_path <- here::here()
project_path <- paste0(DiAna_path, "/projects/tutorial/")
```

By running this code, you establish a structured subproject environment.
The “tutorial” folder will contain the necessary files and
configurations for your subproject, ensuring a seamless and organized
analysis experience.

Finally, we save the script in the subproject folder, using the blue
floppy icon above the script.

### **Input data and packages**

In the DiAna package, seamless data import is a crucial aspect of
empowering pharmacovigilance analyses. The first code chunk utilizes the
import() function to load essential datasets from the FDA Adverse Event
Reporting System (FAERS). By importing datasets like “DRUG,” “REAC,”
“DEMO,” and “INDI,” DiAna equips users with comprehensive information
about drugs, adverse reactions, patient demographics, and indications.

``` r
## Packages -------------------------------------------------------------------
library(DiAna)

## Input FAERS ---------------------------------------------------------------
import("DRUG")
import("REAC")
import("DEMO")
import("INDI")

# Try also importing and look at the information included in DEMO_SUPP, OUTC, THER, DOSES, DRUG_SUPP, DRUG_NAME
```

| primaryid | sex | age_in_days | wt_in_kgs | occr_country             | event_dt | occp_cod | reporter_country         | rept_cod | init_fda_dt |   fda_dt | premarketing | literature | RB_duplicates | RB_duplicates_only_susp |
|----------:|:----|------------:|----------:|:-------------------------|---------:|:---------|:-------------------------|:---------|------------:|---------:|:-------------|:-----------|:--------------|:------------------------|
| 883619455 | F   |          NA |       117 | NA                       | 20120101 | HP       | Canada                   | EXP      |    20121011 | 20230331 | FALSE        | FALSE      | FALSE         | FALSE                   |
|  89418103 | M   |        4015 |        NA | France, French Republic  |       NA | HP       | France, French Republic  | EXP      |    20121203 | 20230331 | FALSE        | TRUE       | FALSE         | FALSE                   |
|  89516744 | M   |        4015 |        NA | France, French Republic  |       NA | HP       | France, French Republic  | EXP      |    20121204 | 20230331 | FALSE        | TRUE       | FALSE         | FALSE                   |
|  89516903 | M   |        2920 |        NA | France, French Republic  |       NA | HP       | France, French Republic  | EXP      |    20121204 | 20230331 | FALSE        | TRUE       | FALSE         | FALSE                   |
|  90224005 | M   |          NA |        NA | Canada                   | 20020201 | MD       | Canada                   | EXP      |    20130118 | 20230331 | FALSE        | FALSE      | FALSE         | FALSE                   |
|  91610302 | F   |        7665 |        NA | United States of America |       NA | HP       | United States of America | PER      |    20130313 | 20230331 | FALSE        | TRUE       | FALSE         | FALSE                   |

Example of demographics data

| primaryid | pt               | drug_rec_act |
|----------:|:-----------------|:-------------|
| 998834879 | weight increased | NA           |
| 998834879 | joint noise      | NA           |
|  99953304 | drug interaction | NA           |
|  99953304 | breast cancer    | NA           |
|  99974963 | breast cancer    | NA           |
|  99974963 | drug interaction | NA           |

Example of reaction data

| primaryid | drug_seq | substance     | role_cod |
|----------:|---------:|:--------------|:---------|
|  99974963 |        5 | dexamethasone | I        |
|  99974963 |        6 | ibuprofen     | I        |
|  99974963 |        7 | lorazepam     | I        |
|  99974963 |        8 | NA            | I        |
|  99974963 |        9 | paracetamol   | I        |
|  99974963 |       10 | zolmitriptan  | SS       |

Example of drug data

| primaryid | drug_seq | indi_pt                             |
|----------:|---------:|:------------------------------------|
|  99974963 |        5 | product used for unknown indication |
|  99974963 |        6 | product used for unknown indication |
|  99974963 |        7 | product used for unknown indication |
|  99974963 |        8 | product used for unknown indication |
|  99974963 |        9 | product used for unknown indication |
|  99974963 |       10 | migraine                            |

Example of indication data

Moreover, DiAna offers functionality to import data related to the
Anatomical Therapeutic Chemical (ATC) classification linked to the
active ingredients as translated by the DiAna dictionary. This ATC file
is a crucial component for grouping drugs based on their therapeutic
use. Please note that we cannot provide the Medical Dictionary for
Regulatory Activities (MedDRA), which is only upon subscription, and
therefore the import_MedDRA function will not work for you. If you have
access to MedDRA, you can follow the instructions on the GitHub
repository to create the MedDRA file for the import_MedDRA function.

``` r
import_ATC()
# we cannot make the meddra available because it is only upon subscription, but here we usually also use the import_MedDRA()) function for grouping events
```

| substance                                | code    | primary_code | Lvl4  | Class4                                                  | Lvl3 | Class3                      | Lvl2 | Class2                           | Lvl1 | Class1                    |
|:-----------------------------------------|:--------|:-------------|:------|:--------------------------------------------------------|:-----|:----------------------------|:-----|:---------------------------------|:-----|:--------------------------|
| antacids, unspecified                    | A02A    | A02A         | A02A  | NA                                                      | A02A | Antacids                    | A02  | Drugs for acid related disorders | A    | Alimentary and Metabolism |
| sodium perborate                         | A01AB19 | A01AB19      | A01AB | Antiinfectives and antiseptics for local oral treatment | A01A | Stomatological preparations | A01  | Stomatological preparations      | A    | Alimentary and Metabolism |
| domiphen                                 | A01AB06 | A01AB06      | A01AB | Antiinfectives and antiseptics for local oral treatment | A01A | Stomatological preparations | A01  | Stomatological preparations      | A    | Alimentary and Metabolism |
| sodium monofluorophosphate               | A01AA02 | A01AA02      | A01AA | Caries prophylactic agents                              | A01A | Stomatological preparations | A01  | Stomatological preparations      | A    | Alimentary and Metabolism |
| sodium fluoride                          | A01AA01 | A01AA01      | A01AA | Caries prophylactic agents                              | A01A | Stomatological preparations | A01  | Stomatological preparations      | A    | Alimentary and Metabolism |
| stomatological preparations, unspecified | A01A    | A01A         | A01A  | NA                                                      | A01A | Stomatological preparations | A01  | Stomatological preparations      | A    | Alimentary and Metabolism |

Example of ATC data

### **Selecting analysis parameters**

In this code chunk, we define the specific parameters for our analysis
in DiAna. **`drugs_selected`** is set to “haloperidol,” representing the
drug of interest, and **`events_selected`** is set to “pneumonia,”
indicating the adverse event under investigation. These parameters play
a pivotal role in guiding the disproportionality analysis. By specifying
the drug and adverse event of focus, users can narrow down their
analysis to a particular scenario, allowing for a more targeted and
insightful exploration of adverse event patterns related to the selected
drug. The flexibility to customize these and other parameters (e.g.,
population), as we will see in the following paragraphs, enhances the
precision of the analysis, enabling users to derive meaningful
conclusions about drug safety within the pharmacovigilance framework.

``` r
drugs_selected <- "haloperidol"

events_selected <- "pneumonia"
```

Note that while events are coded to MedDRA, drugs are submitted to the
FAERS as free text and need a standardization. We implemented a
FAERS-specific DiAna dictionary
(<https://doi.org/10.1101/2023.06.07.23291076>). The get_drugnames
function allows to retrieve the drugnames that were translated to the
drug of interest. Here we show the first 20.

``` r
t <- get_drugnames(drugs_selected)
```

| drugname                                     |     N | perc |
|:---------------------------------------------|------:|-----:|
| haloperidol                                  | 23579 | 0.49 |
| haldol                                       | 16764 | 0.35 |
| haloperidol decanoate                        |  1422 | 0.03 |
| haldol decanoate                             |  1079 | 0.02 |
| serenace                                     |  1064 | 0.02 |
| serenase                                     |   513 | 0.01 |
| haloperidol lactate                          |   450 | 0.01 |
| haldol decanoas                              |   413 | 0.01 |
| serenase /00027401                           |   190 | 0.00 |
| halomonth                                    |   176 | 0.00 |
| serenase (haloperidol)                       |   138 | 0.00 |
| haldol solutab                               |   134 | 0.00 |
| haloperidol injection (manufacturer unknown) |   123 | 0.00 |
| linton                                       |   122 | 0.00 |
| haloperidol (unknown)                        |    98 | 0.00 |
| haloperidol (haloperidol) (haloperidol)      |    81 | 0.00 |
| haldol /00027401                             |    56 | 0.00 |
| haloperidol (watson laboratories)            |    53 | 0.00 |
| aloperidin                                   |    50 | 0.00 |
| neoperidol                                   |    49 | 0.00 |

### **Cases identification and retrieval**

In this code segment, we delve into the process of cases identification
and retrieval within the DiAna package. Firstly, reports associated with
the specified drug of interest, denoted as **`drugs_selected`**, are
identified using the Drug dataset. Similarly, adverse event reports
related to the chosen event (**`events_selected`**) are extracted from
the Reac dataset. The intersection of these two sets of primary IDs
(**`pids_drugs`** and **`pids_events`**) identifies cases where both the
drug and the adverse event are reported. These cases are crucial for
in-depth individual assessment and analysis.

``` r
# we identify the reports with the drug
pids_drugs <- unique(Drug[substance %in% drugs_selected]$primaryid)

# we identify the reports with the event
pids_events <- unique(Reac[pt %in% events_selected]$primaryid)

# we identify cases as reports with both the drug and the event
pids_cases <- intersect(pids_drugs, pids_events)
```

To facilitate further scrutiny and analysis, DiAna offers the
**`retrieve()`** function, which gathers the information about these
identified cases from the different FAERS dataset and stores it into two
Excel files: one with a row for each case, one with multiple rows for
each case recording more detailed drug information. The **`file_name`**
parameter, specified as **`paste0(project_path, "individual_cases")`**,
ensures that the retrieved cases are stored within the designated
subproject folder.

``` r
# retrieve the cases into an excel for individual assessment
retrieve(pids_cases, file_name = paste0(project_path, "individual_cases"))
```

This step is pivotal, allowing pharmacovigilance experts to conduct
detailed examinations of individual cases, thereby enhancing the
precision and depth of the analysis. DiAna’s seamless case retrieval
mechanism simplifies the process, empowering users to focus on in-depth
assessments of specific adverse event patterns associated with the
chosen drug. In particular, it allows to identify duplicates not
detected with the implemented algorithms and identify potential
alternative causes and risk factors.

| primaryid | outc_cod | rpsr_cod          | sex | age_in_days | wt_in_kgs | occr_country | event_dt | occp_cod | reporter_country | rept_cod | init_fda_dt |   fda_dt | premarketing | literature | RB_duplicates | RB_duplicates_only_susp | age_in_years | substance                                                                                                                                                                                                                                                                                                                                                                                | pt                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | pt_rechallenged |
|----------:|:---------|:------------------|:----|------------:|----------:|:-------------|---------:|:---------|:-----------------|:---------|------------:|---------:|:-------------|:-----------|:--------------|:------------------------|-------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:----------------|
|   4322006 | HO       | HP                | M   |       21900 |        NA | NA           | 20031216 | MD       | NA               | EXP      |          NA | 20040323 | FALSE        | FALSE      | FALSE         | FALSE                   |           60 | (haloperidol; clozapine); (clonazepam)                                                                                                                                                                                                                                                                                                                                                   | (anaemia); (feeling abnormal); (liver disorder); (pneumonia); (blood albumin decreased); (blood alkaline phosphatase increased; blood lactate dehydrogenase increased); (body temperature increased; general physical condition abnormal); (coagulation factor vii level decreased; coagulation factor x level decreased; lymphocyte morphology abnormal; monocyte morphology abnormal; prothrombin level decreased); (drug level increased); (laboratory test abnormal); (mania)                                                                                                                      | NA              |
|   4378204 | HO       | SDY; HP           | F   |       20805 |        69 | NA           | 20030321 | MD       | NA               | EXP      |          NA | 20040609 | FALSE        | FALSE      | FALSE         | FALSE                   |           57 | (pseudoephedrine); (hydrocodone); (diphenhydramine); (paracetamol); (lorazepam); (haloperidol); (dextropropoxyphene); (pemetrexed); (carboplatin); (hydrocortisone); (vitamin b9); (famotidine); (calcium)                                                                                                                                                                               | (febrile neutropenia); (pneumonia); (sputum culture positive)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | NA              |
|   4379766 | HO       | HP                | F   |       20805 |        69 | NA           | 20030321 | OT       | NA               | EXP      |          NA | 20040617 | FALSE        | FALSE      | FALSE         | FALSE                   |           57 | (pseudoephedrine); (hydrocodone); (diphenhydramine); (paracetamol); (lorazepam); (haloperidol); (dextropropoxyphene); (pemetrexed); (carboplatin); (hydrocortisone); (vitamin b9); (famotidine); (calcium)                                                                                                                                                                               | (febrile neutropenia); (pneumonia)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | NA              |
|   4383607 | DE; HO   | NA                | M   |       16425 |        NA | NA           | 20040401 | MD       | NA               | EXP      |          NA | 20040623 | FALSE        | FALSE      | FALSE         | FALSE                   |           45 | (venlafaxine); (valproic acid); (olanzapine; haloperidol; clozapine); (lorazepam); (benzatropine)                                                                                                                                                                                                                                                                                        | (lymphopenia); (thrombocytopenia); (atrial flutter; tachycardia); (cardiac failure); (myocarditis); (death); (gait disturbance; gait disturbance; malaise); (pyrexia); (cellulitis); (pneumonia); (mycoplasma infection); (fall; injury); (rib fracture); (haemoglobin decreased); (oxygen saturation decreased); (decreased appetite); (peroneal nerve palsy); (somnolence); (flat affect); (restlessness); (hypotension)                                                                                                                                                                             | NA              |
|   4448307 | HO       | LIT; HP           | M   |       12410 |        NA | NA           |       NA | MD       | NA               | EXP      |          NA | 20040910 | FALSE        | FALSE      | FALSE         | FALSE                   |           34 | (olanzapine; haloperidol; clozapine); (benzatropine); (propranolol)                                                                                                                                                                                                                                                                                                                      | (eosinophilia); (meningitis; pneumonia); (blood pressure systolic increased; heart rate increased); (body temperature increased; respiratory rate increased); (fungal test positive); (white blood cell count increased); (lethargy); (pleural effusion); (rash erythematous)                                                                                                                                                                                                                                                                                                                          | NA              |
|   4449405 | DE       | LIT; HP; FGN      | F   |       16425 |        NA | NA           |       NA | NA       | NA               | EXP      |          NA | 20040909 | FALSE        | FALSE      | FALSE         | FALSE                   |           45 | (chlorphenamine); (haloperidol); (diazepam); (fludrocortisone; cortisone; betamethasone); (nystatin); (calcitriol); (furosemide); (canrenoic acid); (glucose); (albumin); (rifamycin); (levofloxacin); (gentamicin); (cefaclor); (amoxicillin); (ranitidine; rabeprazole; pantoprazole; omeprazole); (potassium; insulin; clavulanic acid; NA); (metoclopramide); (calcium); (aluminium) | (lymphocytic infiltration); (aortic valve sclerosis); (calcinosis); (hepatic fibrosis); (pneumonia; septic shock); (enterococcal infection; pseudomonas infection; staphylococcal infection); (cachexia); (brain oedema); (cerebral disorder); (renal haemorrhage); (lung infiltration); (toxic epidermal necrolysis)                                                                                                                                                                                                                                                                                  | NA              |
|   4477412 | DE       | LIT; FGN          | F   |       16425 |        NA | NA           | 20021001 | NA       | NA               | EXP      |          NA | 20041013 | FALSE        | FALSE      | FALSE         | FALSE                   |           45 | (haloperidol); (diazepam); (fludrocortisone; cortisone; betamethasone); (nystatin); (calcitriol); (furosemide); (canrenoic acid); (levofloxacin); (itraconazole); (cefaclor); (amoxicillin); (rabeprazole; pantoprazole; omeprazole); (metoclopramide); (calcium); (clavulanic acid; NA)                                                                                                 | (lymphocytic infiltration); (aortic valve sclerosis); (thyroid atrophy); (gastrointestinal mucosal disorder); (vomiting); (condition aggravated); (autoimmune hepatitis; chronic hepatitis; hepatic fibrosis); (pneumonia; septic shock); (enterococcal infection; pseudomonas infection; staphylococcal infection); (blood culture positive); (cachexia); (hypokalaemia); (brain oedema); (agitation); (hallucination); (oliguria); (endometrial atrophy); (ovarian atrophy); (lung infiltration); (respiratory distress); (onychomadesis); (rash macular; toxic epidermal necrolysis); (hypotension) | NA              |
|   4547957 | HO; OT   | NA                | F   |       23725 |        NA | NA           | 20040326 | MD       | NA               | EXP      |          NA | 20050110 | FALSE        | FALSE      | FALSE         | FALSE                   |           65 | (ipratropium); (tramadol); (haloperidol); (fentanyl); (amitriptyline); (doxorubicin); (prednisolone); (pantoprazole); (lactulose); (radiotherapy, unspecified)                                                                                                                                                                                                                           | (lymphadenopathy); (vomiting); (pneumonia; sepsis); (prothrombin time shortened)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | NA              |
|   4549507 | LT; HO   | OTH; LIT; HP; FGN | M   |       24820 |        NA | NA           | 19980209 | MD       | NA               | EXP      |          NA | 20050106 | FALSE        | FALSE      | FALSE         | FALSE                   |           68 | (olanzapine; haloperidol); (metixene); (nifedipine); (cefalexin)                                                                                                                                                                                                                                                                                                                         | (haematotoxicity); (neutropenia); (condition aggravated); (drug resistance; therapy non-responder); (bacterial infection); (bronchitis; pneumonia); (facial bones fracture); (fall; wound); (overdose); (granulocyte count decreased; white blood cell count decreased); (cerebral atrophy); (hyperkinesia; parkinsonism; tremor); (neuroleptic malignant syndrome); (paraesthesia); (delusion); (paranoia; social avoidant behaviour); (psychotic disorder); (aspiration; respiratory failure); (loss of personal independence in daily activities)                                                   | NA              |
|   4579752 | DE       | OTH; HP; FGN      | M   |       28470 |        50 | NA           | 20041124 | NA       | NA               | EXP      |          NA | 20050210 | FALSE        | FALSE      | FALSE         | FALSE                   |           78 | (theophylline; pranlukast); (bromhexine); (ambroxol); (quetiapine; levomepromazine; haloperidol); (estazolam); (biperiden); (diclofenac); (flavoxate); (mexiletine); (etilefrine; dopamine); (iron); (famotidine)                                                                                                                                                                        | (granulocytopenia; leukopenia); (haemorrhagic diathesis); (cardio-respiratory arrest); (multiple organ dysfunction syndrome); (therapeutic product ineffective); (infection in an immunocompromised host; pneumonia; septic shock); (klebsiella infection); (bacterial test positive); (c-reactive protein increased); (depressed level of consciousness); (acute kidney injury); (respiratory failure)                                                                                                                                                                                                | NA              |

| primaryid | indi_pt               | route       | dose_form | dechal | rechal | lot_num | exp_dt | dose_vbm       | start_dt | dur_in_days |   end_dt | time_to_onset | event_dt | val_vbm | nda_num | drugname     | prod_ai | role_cod | substance                 | dose | cum_dose |
|----------:|:----------------------|:------------|:----------|:-------|:-------|:--------|:-------|:---------------|---------:|------------:|---------:|--------------:|---------:|--------:|:--------|:-------------|:--------|:---------|:--------------------------|:-----|:---------|
|   4262909 | oesophageal carcinoma | intravenous | NA        | NA     | NA     | NA      | NA     | NA             | 20030922 |          22 | 20031013 |            25 | 20031016 |       1 | NA      | camptosar    | NA      | SS       | irinotecan                | NA   | NA       |
|   4262909 | oesophageal carcinoma | intravenous | NA        | NA     | NA     | NA      | NA     | NA             | 20030922 |          22 | 20031013 |            25 | 20031016 |       1 | NA      | taxotere     | NA      | PS       | docetaxel                 | NA   | NA       |
|   4262909 | oesophageal carcinoma | intravenous | NA        | NA     | NA     | NA      | NA     | NA             | 20030922 |          25 | 20031016 |            25 | 20031016 |       1 | NA      | fluorouracil | NA      | SS       | fluorouracil              | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | DOSE: 5040 CGY | 20030922 |          25 | 20031016 |            25 | 20031016 |       2 | NA      | radiation    | NA      | SS       | radiotherapy, unspecified | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | prilosec     | NA      | C        | omeprazole                | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | zofran       | NA      | C        | ondansetron               | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | marinol      | NA      | C        | dronabinol                | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | pepcid       | NA      | C        | famotidine                | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | lisinopril   | NA      | C        | lisinopril                | NA   | NA       |
|   4262909 | NA                    | NA          | NA        | NA     | NA     | NA      | NA     | NA             |       NA |          NA |       NA |            NA |       NA |       1 | NA      | insulin      | NA      | C        | insulin                   | NA   | NA       |

### **Descriptive analysis**

Aggregated statistics for this data can also be obtained using a
descriptive function. This function can be used in multiple ways, even
comparing the cases of interest with an appropriate reference group
(RG). We could, for example, check whether individuals taking
haloperidol and developing pneumonia are different from individuals
taking haloperidol and developing other adverse events (as a proxy of
the real population of haloperidol recipients). This may allow to
identify potential confounders and risk factors. It is important to note
that even if tests are performed and p-values are obtained, they only
help in the hypothesis generation algorithm and don’t really identify a
significant difference with the real population.

``` r
# aggregated statistics
descriptive(pids_cases, RG = pids_drugs, drug = drugs_selected, file_name = paste0(project_path, "descriptive.xlsx"))
```

| **Characteristic**      | N_cases | %\_cases | N_controls | %\_controls | **p-value** | **q-value** |
|:------------------------|:--------|:---------|:-----------|:------------|:------------|:------------|
| N                       | 991     | NA       | 37979      | NA          | NA          | NA          |
| **sex**                 | NA      | NA       | NA         | NA          | 0.973       | 0.973       |
| Female                  | 417     | 45.47    | 15,856     | 45.57       | NA          | NA          |
| Male                    | 500     | 54.53    | 18,941     | 54.43       | NA          | NA          |
| Unknown                 | 74      | NA       | 3,182      | NA          | NA          | NA          |
| **Submission**          | NA      | NA       | NA         | NA          | \<0.001     | 0.005       |
| Direct                  | 31      | 3.13     | 2,003      | 5.27        | NA          | NA          |
| Expedited               | 909     | 91.73    | 30,411     | 80.07       | NA          | NA          |
| Periodic                | 51      | 5.15     | 5,565      | 14.65       | NA          | NA          |
| **Reporter**            | NA      | NA       | NA         | NA          | \<0.001     | 0.005       |
| Consumer                | 171     | 18.51    | 7,392      | 20.90       | NA          | NA          |
| Healthcare practitioner | 87      | 9.42     | 3,000      | 8.48        | NA          | NA          |
| Lawyer                  | 10      | 1.08     | 401        | 1.13        | NA          | NA          |
| Other                   | 200     | 21.65    | 8,045      | 22.75       | NA          | NA          |
| Pharmacist              | 59      | 6.39     | 3,630      | 10.26       | NA          | NA          |
| Physician               | 397     | 42.97    | 12,902     | 36.48       | NA          | NA          |
| Unknown                 | 67      | NA       | 2,609      | NA          | NA          | NA          |
| **age_range**           | NA      | NA       | NA         | NA          | \<0.001     | 0.005       |
| Neonate (\<28d)         | 0       | 0.00     | 113        | 0.38        | NA          | NA          |
| Infant (28d-\<2y)       | 1       | 0.13     | 57         | 0.19        | NA          | NA          |

Using different functions we can also identify concomitants (drugs),
comorbidities (indications) and cooccurrent reactions at any level or in
a hierarchycal structure.

``` r
# we describe cooccurrences
head(reporting_rates(pids_cases, entity = "reaction"))
#>                     pt                          label_pt N_pt
#> 1:           pneumonia            pneumonia (100%) [991]  991
#> 2: respiratory failure respiratory failure (11.5%) [114]  114
#> 3:              sepsis              sepsis (11.4%) [113]  113
#> 4:            dyspnoea            dyspnoea (11.1%) [110]  110
#> 5:             pyrexia               pyrexia (11%) [109]  109
#> 6:  pulmonary embolism   pulmonary embolism (9.08%) [90]   90

# we describe indications for haloperidol
head(reporting_rates(pids_cases, entity = "indication", drug_indi = "haloperidol"))
#>                    pt                       label_pt N_pt
#> 1:      schizophrenia    schizophrenia (21.69%) [77]   77
#> 2:          agitation        agitation (10.99%) [39]   39
#> 3: psychotic disorder psychotic disorder (9.3%) [33]   33
#> 4:             nausea            nausea (7.61%) [27]   27
#> 5:           delirium          delirium (5.35%) [19]   19
#> 6:            anxiety           anxiety (5.35%) [19]   19

# we describe concomitant suspected of the event according to the ATC classification
hierarchycal_rates(pids_cases, "substance", drug_role = c("PS", "SS"))
knitr::kable(head(readxl::read_xlsx("/Users/michele.fusaroli/Desktop/DiAna_package/DiAna/projects/tutorial/reporting_rates.xlsx"), 20))
```

| label_Class1             | label_Class2                   | label_Class3                    | label_Class4                                                      | label_substance                |
|:-------------------------|:-------------------------------|:--------------------------------|:------------------------------------------------------------------|:-------------------------------|
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Butyrophenone derivatives (33.6%) \[333\]                         | haloperidol (33.3%) \[330\]    |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Butyrophenone derivatives (33.6%) \[333\]                         | melperone (0.5%) \[5\]         |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Butyrophenone derivatives (33.6%) \[333\]                         | bromperidol (0.2%) \[2\]       |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Butyrophenone derivatives (33.6%) \[333\]                         | pipamperone (0.2%) \[2\]       |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | clozapine (16.35%) \[162\]     |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | olanzapine (11.71%) \[116\]    |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | quetiapine (9.79%) \[97\]      |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | loxapine (0.2%) \[2\]          |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | clotiapine (0.1%) \[1\]        |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Diazepines, oxazepines, thiazepines and oxepines (31.28%) \[310\] | asenapine (0.1%) \[1\]         |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | risperidone (6.46%) \[64\]     |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | aripiprazole (2.12%) \[21\]    |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | paliperidone (1.11%) \[11\]    |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | prothipendyl (0.81%) \[8\]     |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | pimavanserin (0.4%) \[4\]      |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | zotepine (0.2%) \[2\]          |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Other antipsychotics (10.19%) \[101\]                             | brexpiprazole (0.1%) \[1\]     |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Phenothiazines with aliphatic side-chain (3.23%) \[32\]           | levomepromazine (1.61%) \[16\] |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Phenothiazines with aliphatic side-chain (3.23%) \[32\]           | chlorpromazine (1.41%) \[14\]  |
| Nervous (60.04%) \[595\] | Psycholeptics (52.57%) \[521\] | Antipsychotics (51.87%) \[514\] | Phenothiazines with aliphatic side-chain (3.23%) \[32\]           | promazine (0.2%) \[2\]         |

### **Network analysis**

We can also use a network to visualize the syndromic co-reporting of
events:

``` r
network_analysis(pids_cases, width = 5000, height = 5000)
```

![](images/network.png)

### **Disproportionality analysis**

Let’s use a different example to explore the disproportionality_analysis
function. We are investigating 5 manfestations of pathologic impulsivity
(impulse control disorders: “gambling”, “hypersexuality”, “shopping”,
“hyperphagia”, “kleptomania”) together with one known adverse drug
reaction of aripiprazole (“headache”) and one clear bias (“bipolar
disorder” is one of the major indications for using aripiprazole).

``` r
drug_selected <- "aripiprazole" # define the drug of interest
reac_selected <- list( # define the events of interest
  "gambling disorder", "hypersexuality", "compulsive shopping", "hyperphagia", "kleptomania", "bipolar disorder", "headache"
)
```

We perform a disproportionality analysis using the
disproportionality_analysis() function to see whether each of the events
investigated is more reported with the drug of interest than what
expected based on the entire FAERS database assuming that the drug and
the event are independent.And we visualize the information component, a
measure of disproportionality, using a forest plot.

``` r
DPA_df <- disproportionality_analysis( # perform disproportionality analysis
  drug_selected, reac_selected
)
render_forest(DPA_df, "IC", row = "event")
```

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

We found an association between aripiprazole and all the events
investigated apart from headache. Sharing this script, we allow everyone
to replicate the study, to use this study design for their own similar
inquiries, and to make as suggestions to improve the quality of our
evidence, for example taking care of some important biases.

#### Removing distortions due to duplicates

Duplicates may distort our results. DiAna already applied multiple
strategies to detect potential duplicates, and will soon add even more
advanced algorithms. The results of these duplicates detection is stored
in the DEMO dataset.We are using now the RB_duplicates_only_susp
algorithm, that looks for the same exact values in sex, age, country of
occurrence, event date, list of events, and list of suspected drugs.
This way we remove more than 3 milion reports over 16 total reports in
the FAERS (quarterly data) up to 23Q1.Deduplicated reports are selected
as those that are not identified as duplicates by the algorithm.Then we
perform the disproportionality analysis restricting to deduplicated
reports. And we store these results together with the results of the
previous analysis to allow for visual comparison using a forest plot.

``` r
deduplicated <- Demo[RB_duplicates_only_susp == FALSE]$primaryid # identify deduplicated reports
DPA_df_deduplicated <- disproportionality_analysis( # disproportionality analysis with restriction
  drug_selected, reac_selected,
  restriction = deduplicated
)
df <- rbindlist(list( # storing together the results of different analyses
  DPA_df[, nested := "main"],
  DPA_df_deduplicated[, nested := "deduplicated"]
), fill = TRUE)
render_forest(df, "IC", # compare the results using a forest plot
  nested = "nested", row = "event"
)
```

<img src="man/figures/README-unnamed-chunk-15-1.png" width="100%" />

In these cases, in fact, we don’t see much a difference comparing the
analysis on the entire FAERS with the analysis on deduplicated data.
This is not generalizable to other drugs and events, and to other
deduplication algorithms.

#### Conditioning on the indication

Since bipolar disorder is a reason for using aripiprazole, we could
think that patients with bipolar disorder are more susceptible to
impulsivity and impulsive behaviors, and maybe that could be the only
reason for the association between aripiprazole and impulsive behaviors
(what is known as confounding by indication).The way we can mitigate
this bias is by conditioning on the indication, for example restricting
to patients with bipolar disorder alone.We therefore need to import the
Indi dataset.To be more sensitive the search for bipolar disorder, we
want to use the MedDRA hierarchy. Alas, the access to MedDRA is by
subscription only and we cannot provide our ready-to-use file. But with
a prescription you can follow the algorithm deascribed in the
<a href="#0" class="uri">https://github.com/fusarolimichele/DiAna</a> to
make your own DiAna-compatible MedDRA.Thus, we can select only reports
with, among indications, terms included in the hlgt “manic and bipolar
mood disorders and disturbances”. And we repeat again the
disproportionality analysis with a different restriction, and compare
the results using the forest plot.

``` r
import_MedDRA() # import MedDRA hierarchy (available only upon subscription to MedDRA MSSO)
#>          def                                            soc
#>     1:  cong     congenital, familial and genetic disorders
#>     2:   inv                                 investigations
#>     3:   inv                                 investigations
#>     4:   inv                                 investigations
#>     5:   inv                                 investigations
#>    ---                                                     
#> 25408: inj&p injury, poisoning and procedural complications
#> 25409:  preg pregnancy, puerperium and perinatal conditions
#> 25410:  surg                surgical and medical procedures
#> 25411:  surg                surgical and medical procedures
#> 25412: blood           blood and lymphatic system disorders
#>                                                         hlgt
#>     1:        metabolic and nutritional disorders congenital
#>     2:          endocrine investigations (incl sex hormones)
#>     3:          endocrine investigations (incl sex hormones)
#>     4:          endocrine investigations (incl sex hormones)
#>     5:          endocrine investigations (incl sex hormones)
#>    ---                                                      
#> 25408:     procedural related injuries and complications nec
#> 25409: pregnancy, labour, delivery and postpartum conditions
#> 25410:   obstetric and gynaecological therapeutic procedures
#> 25411:             male genital tract therapeutic procedures
#> 25412:                            white blood cell disorders
#>                                                  hlt
#>     1:            inborn errors of steroid synthesis
#>     2:                 reproductive hormone analyses
#>     3:                 reproductive hormone analyses
#>     4:                 reproductive hormone analyses
#>     5:                 reproductive hormone analyses
#>    ---                                              
#> 25408:    non-site specific procedural complications
#> 25409:         normal pregnancy, labour and delivery
#> 25410:                 cervix therapeutic procedures
#> 25411: male genital tract therapeutic procedures nec
#> 25412:                        eosinophilic disorders
#>                                      pt
#>     1:   11-beta-hydroxylase deficiency
#>     2:            17 ketosteroids urine
#>     3:  17 ketosteroids urine decreased
#>     4:  17 ketosteroids urine increased
#>     5:     17 ketosteroids urine normal
#>    ---                                 
#> 25408:     incision site skin puckering
#> 25409: spontaneous rupture of membranes
#> 25410:           cervix stent placement
#> 25411:           sperm cryopreservation
#> 25412:      paraneoplastic eosinophilia
bipolar_disorder <- Indi[indi_pt %in% MedDRA[ # select reports with bipolar disorder among indications
  hlgt == "manic and bipolar mood disorders and disturbances"
]$pt]$primaryid

## if MedDRA not available you can use isntead:
# bipolar_disorder <- Indi[indi_pt =="bipolar disorder]$primaryid

DPA_df_bipolar <- disproportionality_analysis( # disproportionality analysis with restriction
  drug_selected, reac_selected,
  restriction = bipolar_disorder
)

df <- rbindlist(list( # storing together the results of different analyses
  df, DPA_df_bipolar[, nested := "bipolar"]
), fill = TRUE)

render_forest(df, "IC", # compare the results using a forest plot
  nested = "nested", row = "event"
)
```

<img src="man/figures/README-unnamed-chunk-16-1.png" width="100%" />

Conditioning on the indication, we see that the association with bipolar
disorder disappears (as it should be). Also the association with impulse
control disorders is weakened, supporting the hypothesis that bipolar
disorder is a risk factor for impulsivity but it is not sufficient alone
to completely explain these pervasive behaviors. The confidence interval
of kleptomania gets wider, since the number of cases gets too small, and
the signal disappear.We can also see that the signal for headache, which
is not associated with bipolar disorder, is not affected by this
restriction.

#### Conditioning on the date of submission

The FDA warning in 2016 may have inflated the reporting distorting the
results (i.e., notoriety bias). To mitigate this bias we can select only
reports submitted before the date of the warning, and repeating the
disproportionality analysis.

``` r
warning_date <- 20160305 # define the warning date
pre_warning <- Demo[init_fda_dt < warning_date]$primaryid # select only reports submitted before the warning
preW <- disproportionality_analysis( # disproportionality analysis with restriction
  drug_selected, reac_selected,
  restriction = pre_warning
)

df <- rbindlist(list( # storing together the results of different analyses
  df, preW[, nested := "pre_warning"]
), fill = TRUE)

render_forest(df, "IC", # compare the results using a forest plot
  nested = "nested", row = "event"
)
```

<img src="man/figures/README-unnamed-chunk-17-1.png" width="100%" />

Here you see in green the results of the analysis restricting to the
pre-warning. You can see that this analysis does not affect bipolar
disorder nor headache, but it affects all the impulse control disorders
apart gambling. Plausibly the FDA warning was based mainly on suspect
aripiprazole-induced gambling disorder.

#### Custom event groupings

MedDRA, used to code adverse events, is highly redundant: there are
multiple terms that may be used to express the same concept. Therefore a
more sensitive and specific approach should take into account all these
terms.We can therefore redefine our reactions of interest for higher
sensitivity.

``` r
reac_selected <- list( # redefined reaction for higher sensitivity
  "gambling disorder" = list("gambling disorder", "gambling"),
  "hypersexuality" = list("compulsive sexual behaviour", "hypersexuality", "excessive masturbation", "excessive sexual fantasies", "libido increased", "sexual activity increased", "kluver-bucy syndrome", "erotophonophilia", "exhibitionism", "fetishism", "frotteurism", "masochism", "paraphilia", "paedophilia", "sadism", "transvestism", "voyeurism", "sexually inappropriate behaviour"),
  "compulsive shopping" = list("compulsive shopping"),
  "hyperphagia" = list("binge eating", "food craving", "hyperphagia", "increased appetite"),
  "kleptomania" = list("kleptomania", "shoplifting"),
  "bipolar disorder" = as.list(MedDRA[hlt == "bipolar disorders"]$pt),
  "headache" = as.list(MedDRA[hlgt == "headaches"]$pt)
)

custom_group <- disproportionality_analysis( # perform the disproportionality analysis
  drug_selected, reac_selected,
  meddra_level = "custom"
)

df <- rbindlist(list( # storing together the results of different analyses
  df, custom_group[, nested := "custom-groups"]
), fill = TRUE)

render_forest(df, "IC", # compare the results using a forest plot
  nested = "nested", row = "event"
)
```

<img src="man/figures/README-unnamed-chunk-18-1.png" width="100%" />

As we can see here custom groups affect mainly kleptomania. Indeed many
reporters prefer to use shoplifting instead of kleptomania, and
therefore the signal is now much stronger.# Complete analysisIn
conclusion, we can integrate all the restrictions and use custom groups
to have a unified analysis.

``` r
restriction <- intersect(intersect(deduplicated, bipolar_disorder), pre_warning) # integrate all the restrictions
complete <- disproportionality_analysis( # disproportionality
  drug_selected, reac_selected,
  meddra_level = "custom", restriction = restriction
)
render_forest(complete, "IC", # forest plot
  row = "event"
)
```

<img src="man/figures/README-unnamed-chunk-19-1.png" width="100%" />

Therefore, you can see that even before the warning and taking into
account all the considered biases, the FDA had enough information to
publish the warning.

## Conclusion

Congratulations! You have successfully conducted basic
disproportionality analysis using DiAna. This vignette covered the
installation of the package, downloading necessary files, and the basic
usage of its functionalities. DiAna empowers the pharmacovigilance
community to make informed decisions and contribute to the collective
knowledge of drug safety.

For more advanced analyses and detailed explanations, explore our
advanced vignettes and documentation (in progress). DiAna is here to
simplify your pharmacovigilance journey and foster collaboration within
the community.

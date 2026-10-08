# Retrieve data for specific primaryids

This function retrieves data for a specific group of primaryids,
allowing for in-depth case-by-case evaluation and clinical reasoning. If
MedDRA is available PTs are clustered by HLGT.

## Usage

``` r
retrieve(
  pids,
  file_name = "individual_cases",
  temp_reac = Reac,
  temp_drug = Drug,
  temp_demo = Demo,
  temp_demo_supp = Demo_supp,
  temp_outc = Outc,
  temp_ther = Ther,
  temp_doses = Doses,
  temp_drug_supp = Drug_supp,
  temp_indi = Indi,
  temp_drug_name = Drug_name,
  temp_meddra = NA,
  temp_atc = NA,
  save_in_excel = !missing(file_name)
)
```

## Arguments

- pids:

  Primaryids of interest.

- file_name:

  The name of the output xlsx file (default is "individual cases").

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- temp_demo:

  Demo dataset. Defaults to Demo. Can be set to sample_Demo for testing

- temp_demo_supp:

  the Demo_supp databases. Can be set to sample_Demo_Supp for testing

- temp_outc:

  Outc dataset. Can be set to sample_Outc for testing

- temp_ther:

  Ther dataset. Can be set to sample_Ther for testing

- temp_doses:

  the Doses databases. Can be set to sample_Doses for testing

- temp_drug_supp:

  the Drug_supp databases. Can be set to sample_Drug_Supp for testing

- temp_indi:

  Indi dataset. Can be set to sample_Indi for testing

- temp_drug_name:

  the Drug_name databases. Can be set to sample_Drug_Name for testing

- temp_meddra:

  the MedDRA dictionary (a data.table with columns soc, hlgt and pt), if
  available. Defaults to NA because MedDRA requires a subscription.

- temp_atc:

  the ATC classification, as returned by import_ATC(), if available.
  Defaults to NA. Only the primary ATC code of each substance is used.

- save_in_excel:

  Whether to also save the results in an Excel file, `file_name`.
  Defaults to `TRUE` only if `file_name` is supplied.

## Value

A list of two data.tables with individual cases information:
`general_info`, with a row per ICSR, and `drug_info`, with drug
information and multiple rows per ICSR. If `save_in_excel = TRUE`, they
are also saved as `file_name.xlsx` and `file_name_drug.xlsx`.

## Examples

``` r
pids <- unique(sample_Demo[sex == "M"]$primaryid)
cases <- retrieve(pids,
  temp_reac = sample_Reac, temp_drug = sample_Drug, temp_demo = sample_Demo,
  temp_demo_supp = sample_Demo_Supp, temp_outc = sample_Outc,
  temp_ther = sample_Ther, temp_doses = sample_Doses,
  temp_drug_supp = sample_Drug_Supp, temp_indi = sample_Indi,
  temp_drug_name = sample_Drug_Name
)
head(cases$general_info)
#>    primaryid outc_cod rpsr_cod    sex age_in_days wt_in_kgs occr_country
#>        <num>   <char>   <char> <fctr>       <num>     <num>       <fctr>
#> 1:   4315260       OT  HP; FGN      M          NA        NA         <NA>
#> 2:   4450462       HO       HP      M       21900        NA         <NA>
#> 3:   4633603   RI; HO       NA      M       19710        88         <NA>
#> 4:   4649430   HO; OT      CSM      M          NA        NA         <NA>
#> 5:   4745980       HO       NA      M       27010        NA         <NA>
#> 6:   4756942   HO; OT       NA      M       13870       107         <NA>
#>    event_dt occp_cod         reporter_country rept_cod init_fda_dt   fda_dt
#>       <int>   <fctr>                   <fctr>   <fctr>       <int>    <int>
#> 1:       NA       OT                     <NA>      EXP          NA 20040309
#> 2: 20031203     <NA>                     <NA>      EXP          NA 20040914
#> 3: 20041123       OT                     <NA>      DIR          NA 20050412
#> 4:       NA     <NA>                     <NA>      EXP          NA 20050427
#> 5: 20050413       CN United States of America      EXP          NA 20050816
#> 6: 20000101       MD United States of America      EXP          NA 20050830
#>    premarketing literature RB_duplicates RB_duplicates_only_susp age_in_years
#>          <lgcl>     <lgcl>        <lgcl>                  <lgcl>        <num>
#> 1:        FALSE      FALSE         FALSE                    TRUE           NA
#> 2:        FALSE      FALSE         FALSE                   FALSE           60
#> 3:        FALSE      FALSE         FALSE                   FALSE           54
#> 4:        FALSE      FALSE         FALSE                   FALSE           NA
#> 5:        FALSE      FALSE         FALSE                   FALSE           74
#> 6:        FALSE      FALSE         FALSE                   FALSE           38
#>                                                                                                         substance
#>                                                                                                            <char>
#> 1:                                                                           infliximab; azathioprine; budesonide
#> 2: vitamin b3; vitamin e; mexiletine; senna spp; vitamin b12; organ lysate; trazodone; alprazolam; NA; famotidine
#> 3:                                                                                                        insulin
#> 4:                                                               cetirizine; fluticasone; montelukast; salbutamol
#> 5:                                                          rofecoxib; celecoxib; celecoxib; acetylsalicylic acid
#> 6:                                                      rofecoxib; rofecoxib; vitamins, unspecified; valaciclovir
#>                                                                                                                                                                                                                                                                                                                                                                                 pt
#>                                                                                                                                                                                                                                                                                                                                                                             <char>
#> 1:                                                                                                                                                                                                                                                                                                                                                    systemic lupus erythematosus
#> 2:                                                                                                                                                                                                                                                                                                           hepatic function abnormal; lymphocyte stimulation test positive; rash
#> 3:                                                                                                                                                                                                                                                                                                                                                                   hypoglycaemia
#> 4:                                                                                                                                                                                                                                                                                                                           cardiac murmur; respiratory syncytial virus infection
#> 5:                                                                                                                                                                                                                                                                                                                                                           myocardial infarction
#> 6: arteriovenous malformation; arthralgia; arteriosclerosis; atrioventricular block; back injury; blood creatinine increased; musculoskeletal chest pain; arteriosclerosis coronary artery; dizziness; iliotibial band syndrome; joint effusion; joint injury; labile hypertension; meniscus injury; muscle mass; myocardial infarction; panic attack; tendonitis; viral infection
#>                                                               pt_rechallenged
#>                                                                        <char>
#> 1:                                                                         NA
#> 2:                                                                 NA; NA; NA
#> 3:                                                                         NA
#> 4:                                                                     NA; NA
#> 5:                                                                         NA
#> 6: NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA; NA
```

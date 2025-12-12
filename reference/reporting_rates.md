# Reporting rates of events or substances

counts the occurrences of reactions/indications/substance for a given
set of primary IDs. Calculates % as the proportion of individuals
recording the event.

## Usage

``` r
reporting_rates(
  pids_cases,
  entity = "reaction",
  level = "pt",
  drug_role = c("PS", "SS", "I", "C"),
  drug_indi = NA,
  temp_reac = Reac,
  temp_drug = Drug,
  temp_indi = Indi
)
```

## Arguments

- pids_cases:

  Vector of primary IDs to consider for counting reactions.

- entity:

  Entity investigated. It can be one of the following:

  - *reaction*;

  - *indication*;

  - *substance*.

- level:

  The desired MedDRA or ATC level for counting (default is "pt").

- drug_role:

  is only used for substances. By default both suspect and concomitant
  drugs are included.

- drug_indi:

  is only used for indications. By default the indications of all the
  drugs of the selected primaryids are considered, but you can specify a
  vector of drugs.

- temp_reac:

  Reac dataset. Can be set to sample_Reac for testing

- temp_drug:

  Drug dataset. Can be set to sample_Drug for testing

- temp_indi:

  Indi dataset. Can be set to sample_Indi for testing

## Value

A data.table containing counts and percentages of the investigated
entity at the specified level and in descending order.

## Examples

``` r
# select only reports recording paracetamol from the sample dataset,
# and provide the most reported events (at the pt level),
# drugs, and indications (at the PT level).
pids_cases <-
reporting_rates(unique(sample_Drug[substance == "paracetamol"]$primaryid),
 "reaction", "pt",
  temp_reac = sample_Reac,
  temp_drug = sample_Drug, temp_indi = sample_Indi
)
reporting_rates(unique(sample_Drug[substance == "paracetamol"]$primaryid),
  "indication", "pt",
  temp_reac = sample_Reac,
  temp_drug = sample_Drug, temp_indi = sample_Indi
)
#>                                    pt
#>                                 <ord>
#>  1:                              pain
#>  2:              rheumatoid arthritis
#>  3:                         back pain
#>  4:                           anxiety
#>  5:  gastrooesophageal reflux disease
#>  6:                        depression
#>  7:                      hypertension
#>  8:               plasma cell myeloma
#>  9:                         psoriasis
#> 10:                            asthma
#> 11:          type 2 diabetes mellitus
#> 12:                     premedication
#> 13:                          covid-19
#> 14:             psoriatic arthropathy
#> 15:                affective disorder
#> 16:                psychotic disorder
#> 17:           intentional self-injury
#> 18:                 candida infection
#> 19:              ill-defined disorder
#> 20: low density lipoprotein increased
#> 21:              abdominal pain upper
#> 22:                     muscle spasms
#> 23:                         neuralgia
#> 24:                 breakthrough pain
#> 25:                          migraine
#> 26:                          insomnia
#> 27:      systemic lupus erythematosus
#> 28:                      chemotherapy
#> 29:                  hypersensitivity
#> 30:                     contraception
#> 31:          mucopolysaccharidosis vi
#> 32:         chronic myeloid leukaemia
#> 33:                multiple sclerosis
#> 34:             oral fungal infection
#> 35:               atrial fibrillation
#> 36:                postoperative care
#> 37:        cardiac failure congestive
#> 38:                          cachexia
#> 39:                       tonsillitis
#> 40:                         dyspepsia
#> 41:                              gout
#> 42:                calcium deficiency
#> 43:              vitamin d deficiency
#> 44:                  blood phosphorus
#> 45:                     renal failure
#> 46:                           anaemia
#> 47:                        leukopenia
#> 48:                   crohn's disease
#> 49:             infection prophylaxis
#> 50:        essential thrombocythaemia
#> 51:  immunodeficiency common variable
#> 52:           acute myeloid leukaemia
#> 53:              pancreatic carcinoma
#> 54:            influenza like illness
#> 55:                           pyrexia
#> 56:                            chills
#> 57:                         infection
#> 58:           blood pressure abnormal
#> 59:                      renal injury
#> 60:        blood cholesterol abnormal
#> 61:                  cardiac disorder
#> 62:                             cough
#> 63:                       rhinorrhoea
#> 64:       upper-airway cough syndrome
#> 65:                   fabry's disease
#> 66:                colitis ulcerative
#> 67:             covid-19 immunisation
#>                                    pt
#>                                          label_pt  N_pt
#>                                            <char> <int>
#>  1:                             pain (17.95%) [7]     7
#>  2:              rheumatoid arthritis (7.69%) [3]     3
#>  3:                         back pain (7.69%) [3]     3
#>  4:                           anxiety (7.69%) [3]     3
#>  5:  gastrooesophageal reflux disease (7.69%) [3]     3
#>  6:                        depression (7.69%) [3]     3
#>  7:                      hypertension (5.13%) [2]     2
#>  8:               plasma cell myeloma (5.13%) [2]     2
#>  9:                         psoriasis (5.13%) [2]     2
#> 10:                            asthma (5.13%) [2]     2
#> 11:          type 2 diabetes mellitus (5.13%) [2]     2
#> 12:                     premedication (5.13%) [2]     2
#> 13:                          covid-19 (5.13%) [2]     2
#> 14:             psoriatic arthropathy (5.13%) [2]     2
#> 15:                affective disorder (2.56%) [1]     1
#> 16:                psychotic disorder (2.56%) [1]     1
#> 17:           intentional self-injury (2.56%) [1]     1
#> 18:                 candida infection (2.56%) [1]     1
#> 19:              ill-defined disorder (2.56%) [1]     1
#> 20: low density lipoprotein increased (2.56%) [1]     1
#> 21:              abdominal pain upper (2.56%) [1]     1
#> 22:                     muscle spasms (2.56%) [1]     1
#> 23:                         neuralgia (2.56%) [1]     1
#> 24:                 breakthrough pain (2.56%) [1]     1
#> 25:                          migraine (2.56%) [1]     1
#> 26:                          insomnia (2.56%) [1]     1
#> 27:      systemic lupus erythematosus (2.56%) [1]     1
#> 28:                      chemotherapy (2.56%) [1]     1
#> 29:                  hypersensitivity (2.56%) [1]     1
#> 30:                     contraception (2.56%) [1]     1
#> 31:          mucopolysaccharidosis vi (2.56%) [1]     1
#> 32:         chronic myeloid leukaemia (2.56%) [1]     1
#> 33:                multiple sclerosis (2.56%) [1]     1
#> 34:             oral fungal infection (2.56%) [1]     1
#> 35:               atrial fibrillation (2.56%) [1]     1
#> 36:                postoperative care (2.56%) [1]     1
#> 37:        cardiac failure congestive (2.56%) [1]     1
#> 38:                          cachexia (2.56%) [1]     1
#> 39:                       tonsillitis (2.56%) [1]     1
#> 40:                         dyspepsia (2.56%) [1]     1
#> 41:                              gout (2.56%) [1]     1
#> 42:                calcium deficiency (2.56%) [1]     1
#> 43:              vitamin d deficiency (2.56%) [1]     1
#> 44:                  blood phosphorus (2.56%) [1]     1
#> 45:                     renal failure (2.56%) [1]     1
#> 46:                           anaemia (2.56%) [1]     1
#> 47:                        leukopenia (2.56%) [1]     1
#> 48:                   crohn's disease (2.56%) [1]     1
#> 49:             infection prophylaxis (2.56%) [1]     1
#> 50:        essential thrombocythaemia (2.56%) [1]     1
#> 51:  immunodeficiency common variable (2.56%) [1]     1
#> 52:           acute myeloid leukaemia (2.56%) [1]     1
#> 53:              pancreatic carcinoma (2.56%) [1]     1
#> 54:            influenza like illness (2.56%) [1]     1
#> 55:                           pyrexia (2.56%) [1]     1
#> 56:                            chills (2.56%) [1]     1
#> 57:                         infection (2.56%) [1]     1
#> 58:           blood pressure abnormal (2.56%) [1]     1
#> 59:                      renal injury (2.56%) [1]     1
#> 60:        blood cholesterol abnormal (2.56%) [1]     1
#> 61:                  cardiac disorder (2.56%) [1]     1
#> 62:                             cough (2.56%) [1]     1
#> 63:                       rhinorrhoea (2.56%) [1]     1
#> 64:       upper-airway cough syndrome (2.56%) [1]     1
#> 65:                   fabry's disease (2.56%) [1]     1
#> 66:                colitis ulcerative (2.56%) [1]     1
#> 67:             covid-19 immunisation (2.56%) [1]     1
#>                                          label_pt  N_pt
reporting_rates(unique(sample_Drug[substance == "paracetamol"]$primaryid),
  entity = "substance",
  temp_reac = sample_Reac, temp_drug = sample_Drug,
  temp_indi = sample_Indi
)
#>                 substance                    label_substance N_substance
#>                    <fctr>                             <char>       <int>
#>   1:          paracetamol            paracetamol (100%) [51]          51
#>   2:            oxycodone            oxycodone (31.37%) [16]          16
#>   3:          hydrocodone          hydrocodone (25.49%) [13]          13
#>   4: acetylsalicylic acid acetylsalicylic acid (19.61%) [10]          10
#>   5:           salbutamol            salbutamol (17.65%) [9]           9
#>  ---                                                                    
#> 264:            enalapril              enalapril (1.96%) [1]           1
#> 265:            aciclovir              aciclovir (1.96%) [1]           1
#> 266:           nifedipine             nifedipine (1.96%) [1]           1
#> 267:         upadacitinib           upadacitinib (1.96%) [1]           1
#> 268:     covid-19 vaccine       covid-19 vaccine (1.96%) [1]           1
```

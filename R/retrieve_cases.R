#' Retrieve data for specific primaryids
#'
#' This function retrieves data for a specific group of primaryids,
#' allowing for in-depth case-by-case evaluation and clinical reasoning.
#' If MedDRA is available PTs are clustered by HLGT.
#'
#' @inheritParams descriptive
#' @param pids Primaryids of interest.
#' @param file_name The name of the output xlsx file (default is "individual cases").
#' @param temp_meddra the MedDRA dictionary, if available. Defaults to NA for subscription requirement.
#' @param temp_atc the ATC classification, if available. Defaults to NA for testing.
#' @param temp_demo_supp the Demo_supp databases. Can be set to sample_Demo_Supp for testing
#' @param temp_doses the Doses databases. Can be set to sample_Doses for testing
#' @param temp_drug_supp the Drug_supp databases. Can be set to sample_Drug_Supp for testing
#' @param temp_drug_name the Drug_name databases. Can be set to sample_Drug_Name for testing
#'
#' @return Two xlsx files with individual cases information:
#'         one general with a row per ICSR,
#'         and one with drug information and multiple rows per ICSR.
#' @importFrom dplyr select
#' @importFrom writexl write_xlsx
#' @importFrom here here
#'
#' @examples
#' FAERS_version <- "24Q1"
#' pids <- sample_Demo[sex == "M"]$primaryid
#' if (file.exists("data/24Q1.csv")) {
#'   retrieve(pids, save_in_excel = FALSE)
#' }
#'
#' @export
retrieve <- function(pids, file_name = "individual_cases",
                     temp_reac = Reac, temp_drug = Drug, temp_demo = Demo,
                     temp_demo_supp = Demo_supp, temp_outc = Outc, temp_ther = Ther,
                     temp_doses = Doses, temp_drug_supp = Drug_supp, temp_indi = Indi,
                     temp_drug_name = Drug_name, temp_meddra = NA, temp_atc = NA,
                     save_in_excel = TRUE) {
  path_MedDRA <- paste0(here::here(), "/external_sources/meddra_primary.csv")

  ## Reactions
  temp_reac <- temp_reac[primaryid %in% pids]
  if (!is.na(temp_meddra)) {
    temp_reac <- temp_meddra[temp_reac, on = "pt"][order(soc)]
    temp_reac <- temp_reac[, .(
      pt = paste0(" (", paste0(pt, collapse = "; "), ")"),
      pt_rechallenged = paste0(
        " (",
        paste0(setdiff(unique(drug_rec_act), NA),
          collapse = "; "
        ), ")"
      )
    ),
    by = c("primaryid", "hlgt")
    ]
  } else {
    temp_reac <- temp_reac[, .(primaryid, pt, pt_rechallenged = drug_rec_act)]
  }
  temp_reac <- temp_reac[, .(
    pt = paste0(pt, collapse = "; "),
    pt_rechallenged = gsub("\\(\\);|;\\(\\)|\\(\\)",
      "",
      paste0(pt_rechallenged,
        collapse = "; "
      ),
      fixed = FALSE
    )
  ),
  by = c("primaryid")
  ]
  ## Drug
  temp_drug <- temp_drug[primaryid %in% pids]
  if (!is.na(temp_atc)) {
    temp_atc[code == primary_code]
    temp_drug <- temp_atc[temp_drug, on = "substance"][order(-substance)][order(-Class1)]
    t_drug1 <- temp_drug[, .(substance = paste0("(", paste0(unique(substance),
      collapse = "; "
    ), ")")),
    by = c("primaryid", "Class3")
    ]
    t_drug1 <- t_drug1[, .(substance = paste0(substance, collapse = "; ")), by = "primaryid"]
  } else {
    t_drug1 <- temp_drug[, .(substance = paste0(substance, collapse = "; ")), by = "primaryid"]
  }


  t <- t_drug1[temp_reac, on = "primaryid"]

  ## Demo
  t <- temp_demo[primaryid %in% pids][
    , age_in_years := round(age_in_days / 365)
  ][
    t,
    on = "primaryid"
  ]
  t <- temp_demo_supp[order(-rpsr_cod)][
    , .(rpsr_cod = paste0(rpsr_cod, collapse = "; ")),
    by = "primaryid"
  ][
    t,
    on = "primaryid"
  ]
  ## Outc
  t <- temp_outc[order(-outc_cod)][
    , .(outc_cod = paste0(outc_cod, collapse = "; ")),
    by = "primaryid"
  ][
    t,
    on = "primaryid"
  ]

  ## Further Drug information
  t_drug2 <- temp_drug[, .(substance = paste0(unique(substance), collapse = ",")),
    by = c("primaryid", "drug_seq", "role_cod")
  ]
  t_drug2 <- merge(temp_drug_name[primaryid %in% pids],
    t_drug2,
    by = c("primaryid", "drug_seq"), all = TRUE
  )
  t_drug2 <- temp_ther[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- temp_doses[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- temp_drug_supp[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- temp_indi[indi_pt != "product used for unknown indication"][
    t_drug2,
    on = c("primaryid", "drug_seq")
  ]
  t_drug2 <- t_drug2[, dose := gsub("NA", "", paste0(dose_amt, " ", dose_unit, " ", dose_freq))][
    , cum_dose := gsub("NA", "", paste0(cum_dose_unit, " ", cum_dose_chr))
  ] %>%
    dplyr::select(-c(dose_amt, dose_unit, dose_freq, drug_seq, cum_dose_unit, cum_dose_chr))
  if (save_in_excel) {
    ## Save the database with general information
    writexl::write_xlsx(t, paste0(file_name, ".xlsx"))
    ## Save the database with further drug information
    writexl::write_xlsx(t_drug2, paste0(file_name, "_drug.xlsx"))
  }
  return(list(general_info = t, drug_info = t_drug2))
}

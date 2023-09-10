#' Retrieve data for specific primaryids
#'
#' This function retrieves data for a specific group of primaryids,
#' allowing for in-depth case-by-case evaluation and clinical reasoning.
#' If MedDRA is available PTs are clustered by HLGT.
#'
#' @param pids Primaryids of interest.
#' @param file_name The name of the output CSV file (default is "individual cases").
#' @param quarter The quarter for data retrieval (default is quarter).
#'
#' @return Two csv files with individual cases information:
#'         one general with a row per ICSR,
#'         and one with drug information and multiple rows per ICSR.
#'
#' @examples
#' \dontrun{
#' retrieve(c(1, 2, 3), "output_data")
#' }
#'
#' @export
retrieve <- function(pids, file_name = "individual_cases", quarter = quarter) {
  ## this function is intended to retrieve all the useful information inherent
  ## to a specific group of primaryids, to allow for in-deep case-by case
  ## evaluation and clinical reasoning.

  ## Args: pids= primaryids of interest
  ##      file_name

  path_MedDRA <- paste0(here(), "/external_sources/meddra_primary.csv")

  ## Reactions
  t_reac <- import("REAC", pids = pids, quarter = quarter)
  if (file.exists(path_MedDRA)) {
    import_MedDRA()
    t_reac <- MedDRA[t_reac, on = "pt"][order(soc)]
    t_reac <- t_reac[, .(
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
  }
  t_reac <- t_reac[, .(
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
  t_drug <- import("DRUG", pids = pids, quarter = quarter)
  import_ATC()[code == primary_code]
  t_drug <- ATC[t_drug, on = "substance"][order(-substance)][order(-Class1)]
  t_drug1 <- t_drug[, .(substance = paste0("(", paste0(unique(substance),
    collapse = "; "
  ), ")")),
  by = c("primaryid", "Class3")
  ]
  t_drug1 <- t_drug1[, .(substance = paste0(substance, collapse = "; ")), by = "primaryid"]

  t <- t_drug1[t_reac, on = "primaryid"]

  ## Demo
  t <- import("DEMO", pids = pids, quarter = quarter)[
    , age_in_years := round(age_in_days / 365)
  ][
    t,
    on = "primaryid"
  ]
  t <- import("DEMO_SUPP", pids = pids, quarter = quarter)[order(-rpsr_cod)][
    , .(rpsr_cod = paste0(rpsr_cod, collapse = "; ")),
    by = "primaryid"
  ][
    t,
    on = "primaryid"
  ]
  ## Outc
  t <- import("OUTC", pids = pids, quarter = quarter)[order(-outc_cod)][
    , .(outc_cod = paste0(outc_cod, collapse = "; ")),
    by = "primaryid"
  ][
    t,
    on = "primaryid"
  ]

  ## Save the database with general information
  write.csv2(t, paste0(file_name, ".csv"))

  ## Further Drug information
  t_drug2 <- t_drug[, .(substance = paste0(unique(substance), collapse = ",")),
    by = c("primaryid", "drug_seq", "role_cod")
  ]
  t_drug2 <- merge(import("DRUG_NAME", pids = pids, quarter = quarter),
    t_drug2,
    by = c("primaryid", "drug_seq"), all = TRUE
  )
  t_drug2 <- import("THER", pids = pids, quarter = quarter)[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- import("DOSES", pids = pids, quarter = quarter)[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- import("DRUG_SUPP", pids = pids, quarter = quarter)[t_drug2, on = c("primaryid", "drug_seq")]
  t_drug2 <- import("INDI", pids = pids, quarter = quarter)[indi_pt != "product used for unknown indication"][
    t_drug2,
    on = c("primaryid", "drug_seq")
  ]
  t_drug2 <- t_drug2[, dose := gsub("NA", "", paste0(dose_amt, " ", dose_unit, " ", dose_freq))][
    , cum_dose := gsub("NA", "", paste0(cum_dose_unit, " ", cum_dose_chr))
  ] %>%
    select(-c(dose_amt, dose_unit, dose_freq, drug_seq, cum_dose_unit, cum_dose_chr))
  ## Save the database with further drug information
  write.csv2(t_drug2, paste0(file_name, "_drug.csv"))
}

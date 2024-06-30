#' Sample Demographic Data
#'
#' A dataset containing demographic information of individuals with various details
#' such as sex, age in days, weight in kilograms, and other related
#' information.
#'
#' @name sample_Demo
#' @format A data frame with 15 variables:
#' \describe{
#'   \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'   \item{sex}{Sex of the individual (\code{factor}), with levels \code{M} for male and \code{F} for female.}
#'   \item{age_in_days}{Age of the individual in days (\code{numeric}).}
#'   \item{wt_in_kgs}{Weight of the individual in kilograms (\code{numeric}).}
#'   \item{occr_country}{Country where the event occurred (\code{factor}).}
#'   \item{event_dt}{Date of the event (\code{integer}), in the format YYYYMMDD.}
#'   \item{occp_cod}{Occupation code of the individual (\code{factor}).}
#'   \item{reporter_country}{Country of the reporter (\code{factor}).}
#'   \item{rept_cod}{Report code (\code{factor}).}
#'   \item{init_fda_dt}{Initial FDA date (\code{integer}), in the format YYYYMMDD.}
#'   \item{fda_dt}{FDA date (\code{integer}), in the format YYYYMMDD.}
#'   \item{premarketing}{Logical indicator if the case is premarketing (\code{logical}).}
#'   \item{literature}{Logical indicator if the case is from literature (\code{logical}).}
#'   \item{RB_duplicates}{Logical indicator if the case is a duplicate based on the Rule Based algorithm (\code{logical}).}
#'   \item{RB_duplicates_only_susp}{Logical indicator if the case is a duplicate based on the Rule Based algorithm considering only suspected drugs (\code{logical}).}
#' }
#' @details
#' This dataset is a subset of the actual Demo data (that can be downloaded using setup_DiAna()),
#' providing a glimpse into the structure of the database and allowing tests and documentation.
#' @docType data
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Demo"

#' Sample dataset containing events (suspected adverse drug reactions) and related information.
#'
#' This dataset provides information on adverse drug reactions (ADRs).
#' Each report (primaryid) can record multiple events (and rows).
#'
#' @name sample_Reac
#' @docType data
#' @format A data.table with 3 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for the report (primary ID)}
#'     \item{pt}{Preferred term describing the adverse reaction according to the Medical Dictionary for Regulatory Activities}
#'     \item{drug_rec_act}{Drug rechallenged action (if the event recurred at the rechallenge, it is going to be shown here).}
#'   }
#' @details
#' This dataset is a subset of the actual Reac data (that can be downloaded using setup_DiAna()),
#' providing a glimpse into the structure of the database and allowing tests and documentation.
#' @docType data
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Reac"

#' Sample dataset containing indications for using reported drugs.
#'
#' This dataset provides information on indications.
#' Each report (primaryid) can record multiple drugs and therefore multiple indications (and rows).
#'
#' @name sample_Indi
#' @docType data
#' @format A data.table with 3 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each report.}
#'     \item{drug_seq}{Sequence number identifying a specific drug reported in a report.}
#'     \item{indi_pt}{Preferred term describing the drug indication according to the Medical Dictionary for Regulatory Activities.}
#'   }
#' @details
#' This dataset provides detailed information on drug indications reported for individuals,
#' categorized by primary ID and drug sequence, facilitating analysis related to specific
#' indications observed in adverse drug reaction reports. Each report can record multiple drugs
#' and therefore multiple indications.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Indi"

#' Sample Data on Individual Outcomes
#'
#' A dataset containing individual-level outcomes associated with adverse drug reactions,
#' linking primary IDs with outcome codes.
#'
#' @name sample_Outc
#' @docType data
#' @format A data.table with 2 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'     \item{outc_cod}{Outcome code indicating the severity or outcome of the adverse event (\code{ordered}).}
#'   }
#' @details
#' This dataset provides information on outcomes associated with reported adverse drug reactions,
#' specifying the severity or nature of each event observed for individuals.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Outc"

#' Sample Data on Therapy Details
#'
#' A dataset containing details on therapeutic interventions, including drug therapy start and end dates,
#' duration in days, time to onset of events related to therapy, and event dates.
#'
#' @name sample_Ther
#' @docType data
#' @format A data.table with 7 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'     \item{drug_seq}{Sequence number identifying the specific drug within the report (\code{integer}).}
#'     \item{start_dt}{Start date of therapy (\code{numeric}), in YYYYMMDD format.}
#'     \item{dur_in_days}{Duration of therapy in days (\code{numeric}).}
#'     \item{end_dt}{End date of therapy (\code{numeric}), in YYYYMMDD format.}
#'     \item{time_to_onset}{Time to onset of related events in days (\code{numeric}). We only have a TTO since we only have an event date for each report}
#'     \item{event_dt}{Date of the related events (\code{integer}), in YYYYMMDD format.}
#'   }
#' @details
#' This subset dataset provides detailed information on therapeutic interventions,
#' It facilitates analysis of therapy durations, and onset times.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Ther"

#' Sample Data on Drug Doses
#'
#' A dataset containing information on drug doses administered,
#' linking primary IDs with dose details.
#'
#' @name sample_Doses
#' @docType data
#' @format A data.table with 7 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'     \item{drug_seq}{Sequence number identifying the specific drug in the report (\code{integer}).}
#'     \item{dose_vbm}{Verbatim dose description (\code{character}).}
#'     \item{dose_unit}{Unit of dose (\code{character}).}
#'     \item{cum_dose_chr}{Cumulative dose as character (\code{numeric}).}
#'     \item{dose_amt}{Amount of dose (\code{character}).}
#'     \item{cum_dose_unit}{Cumulative dose unit (\code{character}).}
#'     \item{dose_freq}{Frequency of dose (\code{factor}).}
#'   }
#' @details
#' This subset of Doses provides detailed information on drug doses administered,
#' including verbatim descriptions, units, cumulative doses, amounts,
#' and frequency of administration, facilitating analysis related to dosing patterns.
#' As it can be observed in the sample, most of the dataset is NA (info not available).
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Doses"

#' Sample Data on Drug Administration
#'
#' A dataset containing information on drugs administered to individuals,
#' including substance names, and roles.
#'
#' @name sample_Drug
#' @docType data
#' @format A data.table with 4 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'     \item{drug_seq}{Sequence number identifying the specific drug in the report (\code{integer}).}
#'     \item{substance}{Name of the drug substance, as standardized using DiAna_Dictionary (\code{factor}).}
#'     \item{role_cod}{Role code indicating the role of the drug (i.e., Primary Suspect, Secondary Suspect, Concomitant, or Interacting) (\code{ordered}).}
#'   }
#' @details
#' This subset of Drug provides detailed information on drugs administered to individuals,
#' specifying their suspected roles in the context of adverse drug reactions.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Drug"

#' Sample Data on Drug Names before standardization
#'
#' A dataset containing information on drug names and associated details,
#' including drug names, and additional attributes.
#'
#' @name sample_Drug_Name
#' @docType data
#' @format A data.table with 5 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each report (\code{numeric}).}
#'     \item{drug_seq}{Sequence number identifying the specific drug in the report (\code{integer}).}
#'     \item{val_vbm}{Validity flag indicating whether the drug name is valid or a free text (not reliable) (\code{integer}).}
#'     \item{nda_num}{New Drug Application number (\code{character}).}
#'     \item{drugname}{Name of the drug as recorded by the reporter (\code{factor}).}
#'     \item{prod_ai}{Product active ingredient as recorded by the reporter (\code{factor}).}
#'   }
#' @details
#' This subset of Drug_Name provides detailed information on drug names and associated attributes.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Drug_Name"

#' Sample Supplementary Demographic Data
#'
#' A dataset containing supplementary demographic information of individuals,
#' including reporter codes, case IDs, and additional details.
#'
#' @name sample_Demo_Supp
#' @docType data
#' @format A data.table with 10 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each individual (\code{numeric}).}
#'     \item{rpsr_cod}{Report source code (\code{factor}).}
#'     \item{caseid}{Case ID to link the report with the public dashboard (\code{integer}).}
#'     \item{caseversion}{Case version in case of multiple updates (\code{factor}).}
#'     \item{i_f_cod}{Initial or follow-up version (\code{factor}).}
#'     \item{auth_num}{Authorization number (\code{character}).}
#'     \item{e_sub}{Electronic submission  (\code{factor}).}
#'     \item{lit_ref}{Literature reference for the case (\code{character}).}
#'     \item{rept_dt}{Reporting date (\code{integer}).}
#'     \item{to_mfr}{Sent to manufacturer (\code{character}).}
#'     \item{mfr_sndr}{Manufacturer sender (\code{character}).}
#'     \item{mfr_num}{Manufacturer id number (\code{character}).}
#'     \item{mfr_dt}{Manufacturer date (\code{integer}).}
#'     \item{quarter}{FAERS Quarter in which the report is stored  (\code{factor}).}
#'   }
#' @details
#' This subset of Demo_Supp provides supplementary demographic information of reports,
#' including details related to reporting and manufacturer information.
#' It is useful for understanding additional context around adverse drug reaction reports.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Demo_Supp"

#' Sample Supplementary Drug Information
#'
#' A dataset containing supplementary information on drugs administered,
#' including administration routes, formulation, and related details.
#'
#' @name sample_Drug_Supp
#' @docType data
#' @format A data.table with 8 variables:
#'   \describe{
#'     \item{primaryid}{Unique identifier for each report (\code{numeric}).}
#'     \item{drug_seq}{Sequence number identifying the specific drug in the report (\code{integer}).}
#'     \item{route}{Route of drug administration (\code{factor}).}
#'     \item{dose_form}{Form of the drug dose (\code{factor}).}
#'     \item{dechal}{Dechallenged flag indicating if dechallenge verified: the event abated at the discontinuation of the drug (\code{factor}).}
#'     \item{rechal}{Rechallenged flag indicating if rechallenge verified: the event reappeared after readminstering the drug (\code{factor}).}
#'     \item{lot_num}{Lot number of the drug (\code{character}).}
#'     \item{exp_dt}{Expiration date of the drug (\code{numeric}).}
#'   }
#' @details
#' This dataset provides supplementary information on drugs administered,
#' including details such as administration routes, dose forms, and dechallenge/rechallenge flags.
#' It complements adverse drug reaction data by providing additional context on drug usage.
#' @keywords datasets
#' @source https://github.com/fusarolimichele/DiAna
"sample_Drug_Supp"

#' Country Dictionary Dataset
#'
#' A dataset containing mappings of country names, their abbreviations, and their respective continents.
#'
#' @format A data frame with 3 variables:
#' \describe{
#'   \item{countryname}{Character. The name of the country, which can include official names and various abbreviations.}
#'   \item{country}{Character. The official name of the country.}
#'   \item{continent}{Character. The continent to which the country belongs.}
#' }
#' @details
#' This dataset provides a comprehensive mapping of country names and their respective continents. It includes various forms of country names such as official names and abbreviations. It is used internally for functions such as descriptive.
#'
"country_dictionary"

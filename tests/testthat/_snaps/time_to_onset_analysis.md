# Plot KS works

    Code
      t <- plot_KS(time_to_onset_analysis(list(`potential anti-acneic` = list(
        "skin care", "adapalene")), list(`skin irritated` = list("erythema",
        "skin irritation", "dry skin")), temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_ther = sample_Ther, minimum_cases = 1, max_TTO = 20, restriction = sample_Demo[
        sex == "F"]$primaryid))

# Render TTO works

    Code
      t <- render_tto(time_to_onset_analysis(list(`potential anti-acneic` = list(
        "skin care", "adapalene")), list(`skin irritated` = list("erythema",
        "skin irritation", "dry skin")), temp_drug = sample_Drug, temp_reac = sample_Reac,
      temp_ther = sample_Ther, minimum_cases = 1, restriction = sample_Demo[sex ==
      "F"]$primaryid))


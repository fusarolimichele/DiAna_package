# Render forest works as usual

    Code
      t <- render_forest(disproportionality_analysis("paracetamol", "nausea",
        sample_Drug, sample_Reac))

# Plot disproportionality trend works as usual

    Code
      t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab",
        "etanercept", "infliximab"), list("injection site pain",
        "injection site reaction", "injection site discomfort"), temp_drug = sample_Drug,
      temp_reac = sample_Reac, temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "quarter"))

---

    Code
      t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab",
        "etanercept", "infliximab"), list("injection site pain",
        "injection site reaction", "injection site discomfort"), temp_drug = sample_Drug,
      temp_reac = sample_Reac, temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "month"), time_granularity = "month")

---

    Code
      t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab",
        "etanercept", "infliximab"), list("injection site pain",
        "injection site reaction", "injection site discomfort"), temp_drug = sample_Drug,
      temp_reac = sample_Reac, temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "quarter"), metric = "ROR", time_granularity = "quarter")

---

    Code
      t <- plot_disproportionality_trend(disproportionality_trend(list("adalimumab",
        "etanercept", "infliximab"), list("injection site pain",
        "injection site reaction", "injection site discomfort"), temp_drug = sample_Drug,
      temp_reac = sample_Reac, temp_demo = sample_Demo, temp_demo_supp = sample_Demo_Supp,
      time_granularity = "month"), metric = "ROR", time_granularity = "month")


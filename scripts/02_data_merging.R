# ============================================
# 02_data_merging.R - Data Merging and Wave Analysis
# ============================================

# ---------------------------------------------
# SETUP
# ---------------------------------------------

# Load setup script
source("scripts/00_setup.R")

message("\n=== PHASE 2: DATA MERGING ===\n")

# ---------------------------------------------
# LOAD PREVIOUS RESULTS
# ---------------------------------------------

message("Loading data from Phase 1...")
data_info <- load_data("01_data_loaded")

diet_raw <- data_info$diet_raw
biomarker_raw <- data_info$biomarker_raw

# ---------------------------------------------
# DETAILED WAVE ANALYSIS
# ---------------------------------------------

cat("\n=== DETAILED WAVE ANALYSIS ===\n")

# Diet data wave distribution
cat("\n--- DIET DATA: RECORDS PER WAVE ---\n")
diet_wave_summary <- diet_raw %>%
  group_by(wave) %>%
  summarise(
    records = n(),
    unique_ids = n_distinct(IDind),
    percentage = round(n() / nrow(diet_raw) * 100, 1)
  ) %>%
  arrange(wave)

print(diet_wave_summary, row.names = FALSE)

# Macronutrient trends by wave
cat("\n--- MACRONUTRIENT TRENDS BY WAVE ---\n")
wave_nutrients <- diet_raw %>%
  group_by(wave) %>%
  summarise(
    n = n(),
    energy_mean = round(mean(d3kcal, na.rm = TRUE), 1),
    energy_sd = round(sd(d3kcal, na.rm = TRUE), 1),
    carb_mean = round(mean(d3carbo, na.rm = TRUE), 1),
    fat_mean = round(mean(d3fat, na.rm = TRUE), 1),
    protein_mean = round(mean(d3protn, na.rm = TRUE), 1)
  )

print(wave_nutrients, row.names = FALSE)

# Individual variability analysis
cat("\n--- INDIVIDUAL DIETARY VARIABILITY ---\n")

# Find individuals with multiple waves
multi_wave_ids <- diet_raw$IDind[duplicated(diet_raw$IDind)]
cat("Individuals with multiple waves:", length(unique(multi_wave_ids)), "\n")

if(length(multi_wave_ids) > 0) {
  multi_wave_data <- diet_raw %>% filter(IDind %in% multi_wave_ids)

  # Calculate within-person changes
  individual_changes <- multi_wave_data %>%
    group_by(IDind) %>%
    summarise(
      waves_count = n(),
      energy_range = max(d3kcal, na.rm = TRUE) - min(d3kcal, na.rm = TRUE),
      carb_range = max(d3carbo, na.rm = TRUE) - min(d3carbo, na.rm = TRUE),
      fat_range = max(d3fat, na.rm = TRUE) - min(d3fat, na.rm = TRUE),
      protein_range = max(d3protn, na.rm = TRUE) - min(d3protn, na.rm = TRUE)
    ) %>%
    summarise(
      avg_waves = mean(waves_count),
      avg_energy_change = round(mean(energy_range, na.rm = TRUE), 1),
      avg_carb_change = round(mean(carb_range, na.rm = TRUE), 1),
      avg_fat_change = round(mean(fat_range, na.rm = TRUE), 1),
      avg_protein_change = round(mean(protein_range, na.rm = TRUE), 1)
    )

  print(individual_changes, row.names = FALSE)
}

# ---------------------------------------------
# MERGING STRATEGY ANALYSIS
# ---------------------------------------------

cat("\n=== MERGING STRATEGY ANALYSIS ===\n")

# Strategy 1: 2009 only (cross-sectional)
cat("\n--- STRATEGY 1: 2009 WAVE ONLY ---\n")
diet_2009 <- diet_raw %>% filter(wave == STUDY_PARAMS$target_wave)
cat("Diet data (2009):", nrow(diet_2009), "records,", length(unique(diet_2009$IDind)), "unique IDs\n")

merge_2009 <- merge(diet_2009, biomarker_raw, by = "IDind", all = FALSE)
cat("Merged (2009):", nrow(merge_2009), "records\n")

# Strategy 2: Latest wave per person
cat("\n--- STRATEGY 2: LATEST WAVE PER PERSON ---\n")
diet_latest <- diet_raw %>%
  group_by(IDind) %>%
  filter(wave == max(wave)) %>%
  ungroup()
cat("Diet data (latest):", nrow(diet_latest), "records,", length(unique(diet_latest$IDind)), "unique IDs\n")

merge_latest <- merge(diet_latest, biomarker_raw, by = "IDind", all = FALSE)
cat("Merged (latest):", nrow(merge_latest), "records\n")

# Strategy 3: Earliest wave per person
cat("\n--- STRATEGY 3: EARLIEST WAVE PER PERSON ---\n")
diet_earliest <- diet_raw %>%
  group_by(IDind) %>%
  filter(wave == min(wave)) %>%
  ungroup()
cat("Diet data (earliest):", nrow(diet_earliest), "records,", length(unique(diet_earliest$IDind)), "unique IDs\n")

merge_earliest <- merge(diet_earliest, biomarker_raw, by = "IDind", all = FALSE)
cat("Merged (earliest):", nrow(merge_earliest), "records\n")

# Compare strategies
cat("\n--- STRATEGY COMPARISON ---\n")
strategy_comparison <- data.frame(
  Strategy = c("2009 Only", "Latest Wave", "Earliest Wave"),
  Diet_Records = c(nrow(diet_2009), nrow(diet_latest), nrow(diet_earliest)),
  Merged_Records = c(nrow(merge_2009), nrow(merge_latest), nrow(merge_earliest)),
  Wave_Alignment = c("Perfect (2009)", "Mixed (1991-2011)", "Mixed (1991-2011)"),
  Scientific_Validity = c("High", "Low", "Low")
)
print(strategy_comparison, row.names = FALSE)

# ---------------------------------------------
# TEMPORAL ALIGNMENT ANALYSIS
# ---------------------------------------------

cat("\n=== TEMPORAL ALIGNMENT ANALYSIS ===\n")

# Analyze wave distribution in merged datasets
cat("\n--- WAVE DISTRIBUTION IN MERGED DATASETS ---\n")

# 2009 strategy (should be all 2009)
wave_dist_2009 <- table(merge_2009$wave.x, useNA = "ifany")
cat("2009 Strategy - Diet waves:", paste(names(wave_dist_2009), collapse = ", "), "\n")

# Latest wave strategy
wave_dist_latest <- table(merge_latest$wave.x, useNA = "ifany")
cat("Latest Strategy - Diet waves:", paste(names(wave_dist_latest), collapse = ", "), "\n")

# Earliest wave strategy
wave_dist_earliest <- table(merge_earliest$wave.x, useNA = "ifany")
cat("Earliest Strategy - Diet waves:", paste(names(wave_dist_earliest), collapse = ", "), "\n")

# Time lag analysis for non-2009 strategies
cat("\n--- TIME LAG ANALYSIS (NON-2009 STRATEGIES) ---\n")

# Latest wave time lag
latest_time_lags <- merge_latest %>%
  mutate(time_lag_years = 2009 - wave.x) %>%
  summarise(
    mean_lag = round(mean(time_lag_years), 1),
    median_lag = round(median(time_lag_years), 1),
    min_lag = min(time_lag_years),
    max_lag = max(time_lag_years)
  )
cat("Latest wave strategy - Time lag from 2009 (years):\n")
print(latest_time_lags, row.names = FALSE)

# Earliest wave time lag
earliest_time_lags <- merge_earliest %>%
  mutate(time_lag_years = 2009 - wave.x) %>%
  summarise(
    mean_lag = round(mean(time_lag_years), 1),
    median_lag = round(median(time_lag_years), 1),
    min_lag = min(time_lag_years),
    max_lag = max(time_lag_years)
  )
cat("Earliest wave strategy - Time lag from 2009 (years):\n")
print(earliest_time_lags, row.names = FALSE)

# ---------------------------------------------
# RECOMMENDED STRATEGY SELECTION
# ---------------------------------------------

cat("\n=== RECOMMENDED MERGING STRATEGY ===\n")

# Select 2009 strategy as recommended
recommended_data <- merge_2009
recommended_strategy <- "2009_only"

cat("RECOMMENDED: 2009 Wave Only Strategy\n")
cat("Rationale:\n")
cat("1. Perfect temporal alignment (diet and biomarkers from same year)\n")
cat("2. Matches original study design (cross-sectional)\n")
cat("3. Biologically valid (blood lipids reflect current diet)\n")
cat("4. Scientifically rigorous (no temporal confounding)\n")
cat("5. Sample size adequate (n =", nrow(recommended_data), ")\n")

# ---------------------------------------------
# SAVE MERGED DATA
# ---------------------------------------------

cat("\n=== SAVING MERGED DATA ===\n")

# Save all merge strategies for comparison
merge_results <- list(
  strategy_2009 = list(
    diet_data = diet_2009,
    merged_data = merge_2009,
    sample_size = nrow(merge_2009)
  ),
  strategy_latest = list(
    diet_data = diet_latest,
    merged_data = merge_latest,
    sample_size = nrow(merge_latest)
  ),
  strategy_earliest = list(
    diet_data = diet_earliest,
    merged_data = merge_earliest,
    sample_size = nrow(merge_earliest)
  ),
  recommended = list(
    strategy = recommended_strategy,
    data = recommended_data,
    rationale = "Perfect temporal alignment with 2009 biomarkers"
  ),
  analysis = list(
    wave_trends = wave_nutrients,
    individual_variability = if(exists("individual_changes")) individual_changes else NULL,
    time_lags = list(latest = latest_time_lags, earliest = earliest_time_lags)
  )
)

save_data(merge_results, "02_data_merged", formats = c("rds"))

message("\n=== PHASE 2 COMPLETE ===")
message("Data merging strategies analyzed")
message("Recommended strategy: 2009 wave only")
message("Saved: 02_data_merged.rds")
message("Ready for Phase 3: Data Quality\n")
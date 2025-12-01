# ============================================
# CHNS Diet and Biomarker Analysis - Comprehensive
# ============================================

# Step 1: Load the data
diet = read.csv("c12diet.csv")
biomarker = read.csv("biomarker.csv")

# Step 2: Check data structure
cat("=== DIET DATA STRUCTURE ===\n")
dim(diet)
names(diet)

cat("\n=== BIOMARKER DATA STRUCTURE ===\n")
dim(biomarker)
names(biomarker)

# Step 3: Check for duplicates
cat("\n=== DUPLICATE ANALYSIS ===\n")
cat("Duplicates in diet:", sum(duplicated(diet$IDind)), "\n")
cat("Duplicates in biomarker:", sum(duplicated(biomarker$IDind)), "\n")
cat("Unique IDs in diet:", length(unique(diet$IDind)), "\n")
cat("Unique IDs in biomarker:", length(unique(biomarker$IDind)), "\n")

# Step 4: Check waves in diet data
cat("\n=== WAVES IN DIET DATA ===\n")
wave_table = table(diet$wave)
print(wave_table)
cat("Total waves:", length(wave_table), "\n")

# Step 5: Check ID overlap
common_ids = intersect(diet$IDind, biomarker$IDind)
only_in_diet = setdiff(diet$IDind, biomarker$IDind)
only_in_biomarker = setdiff(biomarker$IDind, diet$IDind)

cat("\n=== ID OVERLAP ANALYSIS ===\n")
cat("Common IDs:", length(common_ids), "\n")
cat("Only in diet:", length(only_in_diet), "\n")
cat("Only in biomarker:", length(only_in_biomarker), "\n")
cat("Overlap percentage:", round(length(common_ids)/length(unique(biomarker$IDind))*100, 1), "%\n")

# Step 6: Analyze data BEFORE merging
cat("\n=== ANALYSIS BEFORE MERGING ===\n")

# Diet data summary
cat("\n--- DIET DATA SUMMARY ---\n")
cat("Total records:", nrow(diet), "\n")
cat("Unique individuals:", length(unique(diet$IDind)), "\n")
cat("Records per person (mean):", round(nrow(diet)/length(unique(diet$IDind)), 2), "\n")

# Wave distribution
cat("\n--- DIET WAVE DISTRIBUTION ---\n")
wave_summary = data.frame(
  Wave = names(wave_table),
  Records = as.numeric(wave_table),
  Percentage = round(as.numeric(wave_table)/sum(wave_table)*100, 1)
)
print(wave_summary)

# Biomarker data summary
cat("\n--- BIOMARKER DATA SUMMARY ---\n")
cat("Total records:", nrow(biomarker), "\n")
cat("Unique individuals:", length(unique(biomarker$IDind)), "\n")
cat("Wave distribution:", table(biomarker$wave), "\n")

# Macronutrient summary by wave
cat("\n--- MACRONUTRIENTS BY WAVE (DIET) ---\n")
library(dplyr)
wave_nutrients = diet %>%
  group_by(wave) %>%
  summarise(
    n = n(),
    kcal_mean = round(mean(d3kcal, na.rm=TRUE), 1),
    kcal_sd = round(sd(d3kcal, na.rm=TRUE), 1),
    carb_mean = round(mean(d3carbo, na.rm=TRUE), 1),
    fat_mean = round(mean(d3fat, na.rm=TRUE), 1),
    prot_mean = round(mean(d3protn, na.rm=TRUE), 1)
  )
print(wave_nutrients)

# Step 7: Different merging strategies
cat("\n=== MERGING STRATEGIES COMPARISON ===\n")

# Strategy 1: Filter to 2009 wave (cross-sectional)
diet_2009 = diet %>% filter(wave == 2009)
merge_2009 = merge(diet_2009, biomarker, by = "IDind")

# Strategy 2: Use latest wave per person (longitudinal)
diet_latest = diet %>%
  group_by(IDind) %>%
  filter(wave == max(wave)) %>%
  ungroup()
merge_latest = merge(diet_latest, biomarker, by = "IDind")

# Strategy 3: Use earliest wave per person
diet_earliest = diet %>%
  group_by(IDind) %>%
  filter(wave == min(wave)) %>%
  ungroup()
merge_earliest = merge(diet_earliest, biomarker, by = "IDind")

# Compare strategies
strategies = data.frame(
  Strategy = c("2009 only", "Latest wave", "Earliest wave"),
  Diet_Rows = c(nrow(diet_2009), nrow(diet_latest), nrow(diet_earliest)),
  Merged_Rows = c(nrow(merge_2009), nrow(merge_latest), nrow(merge_earliest)),
  Wave_Match = c("Perfect (2009)", "Mixed (1991-2011)", "Mixed (1991-2011)")
)
print(strategies)

# Step 8: Analyze merged data (2009 strategy)
cat("\n=== ANALYSIS OF 2009 MERGED DATA ===\n")
data = merge_2009

cat("Final sample size:", nrow(data), "\n")
cat("Columns:", ncol(data), "\n")

# Check for missing values in key variables
cat("\n--- MISSING VALUES IN KEY VARIABLES ---\n")
key_vars = c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")
missing_summary = data.frame(
  Variable = key_vars,
  Missing = sapply(data[, key_vars], function(x) sum(is.na(x))),
  Percentage = round(sapply(data[, key_vars], function(x) sum(is.na(x))/nrow(data)*100), 1)
)
print(missing_summary)

# Step 9: Summary statistics
cat("\n=== SUMMARY STATISTICS (2009 MERGED DATA) ===\n")
summary(data[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")])

# Step 10: Distribution analysis
cat("\n=== DISTRIBUTION ANALYSIS ===\n")

# Energy intake distribution
cat("\n--- ENERGY INTAKE DISTRIBUTION ---\n")
energy_quartiles = quantile(data$d3kcal, probs = c(0, 0.25, 0.5, 0.75, 1), na.rm = TRUE)
cat("Energy intake quartiles (kcal/day):\n")
print(energy_quartiles)

# Lipid profile distribution
cat("\n--- LIPID PROFILE DISTRIBUTION ---\n")
lipid_summary = data.frame(
  Biomarker = c("TC", "HDL_C", "LDL_C", "TG"),
  Mean = round(c(mean(data$TC, na.rm=TRUE), mean(data$HDL_C, na.rm=TRUE),
                 mean(data$LDL_C, na.rm=TRUE), mean(data$TG, na.rm=TRUE)), 2),
  SD = round(c(sd(data$TC, na.rm=TRUE), sd(data$HDL_C, na.rm=TRUE),
               sd(data$LDL_C, na.rm=TRUE), sd(data$TG, na.rm=TRUE)), 2),
  Median = round(c(median(data$TC, na.rm=TRUE), median(data$HDL_C, na.rm=TRUE),
                   median(data$LDL_C, na.rm=TRUE), median(data$TG, na.rm=TRUE)), 2)
)
print(lipid_summary)

# Step 11: Cross-wave comparison
cat("\n=== CROSS-WAVE COMPARISON ===\n")

# Compare macronutrients across waves (for individuals with multiple waves)
multi_wave_ids = diet$IDind[duplicated(diet$IDind)]
cat("Individuals with multiple waves:", length(unique(multi_wave_ids)), "\n")

if(length(multi_wave_ids) > 0) {
  multi_wave_data = diet %>% filter(IDind %in% multi_wave_ids)
  cat("\n--- MULTI-WAVE INDIVIDUALS ANALYSIS ---\n")
  wave_changes = multi_wave_data %>%
    group_by(IDind) %>%
    summarise(
      waves_count = n(),
      kcal_change = max(d3kcal) - min(d3kcal),
      carb_change = max(d3carbo) - min(d3carbo),
      fat_change = max(d3fat) - min(d3fat),
      prot_change = max(d3protn) - min(d3protn)
    ) %>%
    summarise(
      avg_waves = mean(waves_count),
      avg_kcal_change = round(mean(abs(kcal_change)), 1),
      avg_carb_change = round(mean(abs(carb_change)), 1),
      avg_fat_change = round(mean(abs(fat_change)), 1),
      avg_prot_change = round(mean(abs(prot_change)), 1)
    )
  print(wave_changes)
}

cat("\n=== ANALYSIS COMPLETE ===\n")

# ============================================
# PHASE 4: DATA QUALITY & MISSING VALUES
# Best Practice Implementation
# ============================================

cat("\n")
cat("##############################################\n")
cat("#  PHASE 4: DATA QUALITY & MISSING VALUES   #\n")
cat("##############################################\n")

# Use the 2009 merged dataset
data = merge_2009

# ---------------------------------------------
# 4.1 COMPREHENSIVE MISSING VALUE ANALYSIS
# ---------------------------------------------
cat("\n=== 4.1 MISSING VALUE ANALYSIS ===\n")

# All variables missing check
all_missing = data.frame(
  Variable = names(data),
  N_Total = nrow(data),
  N_Missing = sapply(data, function(x) sum(is.na(x))),
  N_Complete = sapply(data, function(x) sum(!is.na(x))),
  Pct_Missing = round(sapply(data, function(x) sum(is.na(x))/length(x)*100), 2)
)
all_missing = all_missing[order(-all_missing$Pct_Missing), ]

cat("\n--- VARIABLES WITH MISSING VALUES (>0%) ---\n")
vars_with_missing = all_missing[all_missing$Pct_Missing > 0, ]
print(vars_with_missing, row.names = FALSE)

cat("\n--- MISSING VALUE SUMMARY ---\n")
cat("Total variables:", ncol(data), "\n")
cat("Variables with NO missing:", sum(all_missing$Pct_Missing == 0), "\n")
cat("Variables with <5% missing:", sum(all_missing$Pct_Missing > 0 & all_missing$Pct_Missing < 5), "\n")
cat("Variables with 5-20% missing:", sum(all_missing$Pct_Missing >= 5 & all_missing$Pct_Missing < 20), "\n")
cat("Variables with >20% missing:", sum(all_missing$Pct_Missing >= 20), "\n")

# Key outcome variables missing pattern
cat("\n--- KEY OUTCOME VARIABLES (LIPIDS) ---\n")
lipid_vars = c("TC", "HDL_C", "LDL_C", "TG", "TC_MG", "HDL_C_MG", "LDL_C_MG", "TG_MG")
lipid_missing = all_missing[all_missing$Variable %in% lipid_vars, ]
print(lipid_missing, row.names = FALSE)

# Key exposure variables missing pattern
cat("\n--- KEY EXPOSURE VARIABLES (MACRONUTRIENTS) ---\n")
macro_vars = c("d3kcal", "d3carbo", "d3fat", "d3protn")
macro_missing = all_missing[all_missing$Variable %in% macro_vars, ]
print(macro_missing, row.names = FALSE)

# ---------------------------------------------
# 4.2 MISSING VALUE PATTERNS
# ---------------------------------------------
cat("\n=== 4.2 MISSING VALUE PATTERNS ===\n")

# Check if lipid missingness is correlated (MCAR, MAR, MNAR assessment)
lipid_complete = complete.cases(data[, c("TC", "HDL_C", "LDL_C", "TG")])
cat("\n--- LIPID COMPLETENESS ---\n")
cat("Complete lipid data:", sum(lipid_complete), "(", round(sum(lipid_complete)/nrow(data)*100, 1), "%)\n")
cat("Missing any lipid:", sum(!lipid_complete), "(", round(sum(!lipid_complete)/nrow(data)*100, 1), "%)\n")

# Pattern analysis - are same people missing all lipids?
cat("\n--- LIPID MISSING PATTERN ANALYSIS ---\n")
lipid_pattern = data.frame(
  TC_miss = is.na(data$TC),
  HDL_miss = is.na(data$HDL_C),
  LDL_miss = is.na(data$LDL_C),
  TG_miss = is.na(data$TG)
)
lipid_pattern$pattern = paste0(
  ifelse(lipid_pattern$TC_miss, "1", "0"),
  ifelse(lipid_pattern$HDL_miss, "1", "0"),
  ifelse(lipid_pattern$LDL_miss, "1", "0"),
  ifelse(lipid_pattern$TG_miss, "1", "0")
)
pattern_table = as.data.frame(table(lipid_pattern$pattern))
names(pattern_table) = c("Pattern_TC_HDL_LDL_TG", "Frequency")
pattern_table$Percentage = round(pattern_table$Frequency / sum(pattern_table$Frequency) * 100, 2)
pattern_table = pattern_table[order(-pattern_table$Frequency), ]
cat("Pattern: 0=Present, 1=Missing (TC-HDL-LDL-TG)\n")
print(pattern_table, row.names = FALSE)

# ---------------------------------------------
# 4.3 OUTLIER DETECTION
# ---------------------------------------------
cat("\n=== 4.3 OUTLIER DETECTION ===\n")

# Function to detect outliers using IQR method
detect_outliers_iqr = function(x, multiplier = 1.5) {
  q1 = quantile(x, 0.25, na.rm = TRUE)
  q3 = quantile(x, 0.75, na.rm = TRUE)
  iqr = q3 - q1
  lower = q1 - multiplier * iqr
  upper = q3 + multiplier * iqr
  return(list(
    lower = lower,
    upper = upper,
    n_low = sum(x < lower, na.rm = TRUE),
    n_high = sum(x > upper, na.rm = TRUE),
    n_total = sum(x < lower | x > upper, na.rm = TRUE)
  ))
}

# Function to detect outliers using Z-score method
detect_outliers_zscore = function(x, threshold = 3) {
  z = (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
  return(sum(abs(z) > threshold, na.rm = TRUE))
}

cat("\n--- MACRONUTRIENT OUTLIERS (IQR Method, 1.5x) ---\n")
macro_outliers = data.frame(
  Variable = macro_vars,
  N_Low = sapply(data[, macro_vars], function(x) detect_outliers_iqr(x)$n_low),
  N_High = sapply(data[, macro_vars], function(x) detect_outliers_iqr(x)$n_high),
  N_Total = sapply(data[, macro_vars], function(x) detect_outliers_iqr(x)$n_total),
  Pct_Outliers = round(sapply(data[, macro_vars], function(x) detect_outliers_iqr(x)$n_total / sum(!is.na(x)) * 100), 2),
  Lower_Bound = sapply(data[, macro_vars], function(x) round(detect_outliers_iqr(x)$lower, 1)),
  Upper_Bound = sapply(data[, macro_vars], function(x) round(detect_outliers_iqr(x)$upper, 1))
)
print(macro_outliers, row.names = FALSE)

cat("\n--- LIPID OUTLIERS (IQR Method, 1.5x) ---\n")
lipid_outlier_vars = c("TC", "HDL_C", "LDL_C", "TG")
lipid_outliers = data.frame(
  Variable = lipid_outlier_vars,
  N_Low = sapply(data[, lipid_outlier_vars], function(x) detect_outliers_iqr(x)$n_low),
  N_High = sapply(data[, lipid_outlier_vars], function(x) detect_outliers_iqr(x)$n_high),
  N_Total = sapply(data[, lipid_outlier_vars], function(x) detect_outliers_iqr(x)$n_total),
  Pct_Outliers = round(sapply(data[, lipid_outlier_vars], function(x) detect_outliers_iqr(x)$n_total / sum(!is.na(x)) * 100), 2),
  Lower_Bound = sapply(data[, lipid_outlier_vars], function(x) round(detect_outliers_iqr(x)$lower, 2)),
  Upper_Bound = sapply(data[, lipid_outlier_vars], function(x) round(detect_outliers_iqr(x)$upper, 2))
)
print(lipid_outliers, row.names = FALSE)

cat("\n--- Z-SCORE OUTLIERS (|Z| > 3) ---\n")
zscore_outliers = data.frame(
  Variable = c(macro_vars, lipid_outlier_vars),
  N_Extreme = c(
    sapply(data[, macro_vars], detect_outliers_zscore),
    sapply(data[, lipid_outlier_vars], detect_outliers_zscore)
  )
)
print(zscore_outliers, row.names = FALSE)

# ---------------------------------------------
# 4.4 PLAUSIBILITY CHECKS
# ---------------------------------------------
cat("\n=== 4.4 PLAUSIBILITY CHECKS ===\n")

# Energy intake plausibility (per literature: <500 or >5000 kcal/day implausible)
cat("\n--- ENERGY INTAKE PLAUSIBILITY ---\n")
cat("Based on literature: <500 or >5000 kcal/day considered implausible\n\n")
energy_implausible = data.frame(
  Category = c("< 500 kcal/day", "500-800 kcal/day (low)", "800-4000 kcal/day (normal)", 
               "4000-5000 kcal/day (high)", "> 5000 kcal/day"),
  N = c(
    sum(data$d3kcal < 500, na.rm = TRUE),
    sum(data$d3kcal >= 500 & data$d3kcal < 800, na.rm = TRUE),
    sum(data$d3kcal >= 800 & data$d3kcal <= 4000, na.rm = TRUE),
    sum(data$d3kcal > 4000 & data$d3kcal <= 5000, na.rm = TRUE),
    sum(data$d3kcal > 5000, na.rm = TRUE)
  )
)
energy_implausible$Pct = round(energy_implausible$N / nrow(data) * 100, 2)
energy_implausible$Action = c("EXCLUDE", "FLAG", "KEEP", "FLAG", "EXCLUDE")
print(energy_implausible, row.names = FALSE)

# Lipid plausibility checks
cat("\n--- LIPID PLAUSIBILITY CHECKS ---\n")
cat("Clinical reference ranges (mmol/L):\n")
cat("TC: Normal <5.2, Borderline 5.2-6.2, High >6.2\n")
cat("HDL-C: Low <1.0, Normal 1.0-1.5, High >1.5\n")
cat("LDL-C: Normal <2.6, Borderline 2.6-3.4, High >3.4\n")
cat("TG: Normal <1.7, Borderline 1.7-2.3, High >2.3\n\n")

# TC distribution
tc_dist = data.frame(
  Category = c("Very Low (<2.0)", "Low (2.0-3.5)", "Normal (3.5-5.2)", "Borderline (5.2-6.2)", "High (>6.2)", "Extreme (>10)"),
  N = c(
    sum(data$TC < 2.0, na.rm = TRUE),
    sum(data$TC >= 2.0 & data$TC < 3.5, na.rm = TRUE),
    sum(data$TC >= 3.5 & data$TC < 5.2, na.rm = TRUE),
    sum(data$TC >= 5.2 & data$TC <= 6.2, na.rm = TRUE),
    sum(data$TC > 6.2 & data$TC <= 10, na.rm = TRUE),
    sum(data$TC > 10, na.rm = TRUE)
  )
)
tc_dist$Pct = round(tc_dist$N / sum(!is.na(data$TC)) * 100, 1)
cat("Total Cholesterol (TC) Distribution:\n")
print(tc_dist, row.names = FALSE)

# TG distribution (often right-skewed)
cat("\n--- TRIGLYCERIDE DISTRIBUTION (Often Skewed) ---\n")
tg_dist = data.frame(
  Category = c("Normal (<1.7)", "Borderline (1.7-2.3)", "High (2.3-5.6)", "Very High (>5.6)"),
  N = c(
    sum(data$TG < 1.7, na.rm = TRUE),
    sum(data$TG >= 1.7 & data$TG < 2.3, na.rm = TRUE),
    sum(data$TG >= 2.3 & data$TG <= 5.6, na.rm = TRUE),
    sum(data$TG > 5.6, na.rm = TRUE)
  )
)
tg_dist$Pct = round(tg_dist$N / sum(!is.na(data$TG)) * 100, 1)
print(tg_dist, row.names = FALSE)

# Skewness check for TG (may need log-transformation)
cat("\n--- SKEWNESS ANALYSIS ---\n")
# Manual skewness calculation
calc_skewness = function(x) {
  x = x[!is.na(x)]
  n = length(x)
  m = mean(x)
  s = sd(x)
  skew = (sum((x - m)^3) / n) / (s^3)
  return(round(skew, 3))
}

skewness_results = data.frame(
  Variable = c("d3kcal", "TC", "HDL_C", "LDL_C", "TG"),
  Skewness = c(
    calc_skewness(data$d3kcal),
    calc_skewness(data$TC),
    calc_skewness(data$HDL_C),
    calc_skewness(data$LDL_C),
    calc_skewness(data$TG)
  )
)
skewness_results$Interpretation = ifelse(abs(skewness_results$Skewness) < 0.5, "Symmetric",
                                   ifelse(abs(skewness_results$Skewness) < 1, "Moderate Skew", "High Skew"))
skewness_results$Transformation = ifelse(skewness_results$Skewness > 1, "Consider log()", "None needed")
print(skewness_results, row.names = FALSE)

# ---------------------------------------------
# 4.5 DATA QUALITY FLAGS & EXCLUSION CRITERIA
# ---------------------------------------------
cat("\n=== 4.5 DATA QUALITY FLAGS ===\n")

# Create quality flags
data$flag_energy_low = data$d3kcal < 500
data$flag_energy_high = data$d3kcal > 5000
data$flag_lipid_missing = !complete.cases(data[, c("TC", "HDL_C", "LDL_C", "TG")])
data$flag_tc_extreme = data$TC > 10 | data$TC < 2
data$flag_tg_extreme = data$TG > 10

# Summary of flags
cat("\n--- QUALITY FLAG SUMMARY ---\n")
flag_summary = data.frame(
  Flag = c("Energy < 500 kcal", "Energy > 5000 kcal", "Missing any lipid", 
           "TC extreme (<2 or >10)", "TG extreme (>10)"),
  N_Flagged = c(
    sum(data$flag_energy_low, na.rm = TRUE),
    sum(data$flag_energy_high, na.rm = TRUE),
    sum(data$flag_lipid_missing, na.rm = TRUE),
    sum(data$flag_tc_extreme, na.rm = TRUE),
    sum(data$flag_tg_extreme, na.rm = TRUE)
  )
)
flag_summary$Pct = round(flag_summary$N_Flagged / nrow(data) * 100, 2)
flag_summary$Recommendation = c("EXCLUDE", "EXCLUDE", "EXCLUDE from lipid analysis",
                                 "EXCLUDE", "EXCLUDE")
print(flag_summary, row.names = FALSE)

# Combined exclusions
data$exclude_any = data$flag_energy_low | data$flag_energy_high | 
                   data$flag_lipid_missing | 
                   (data$flag_tc_extreme & !is.na(data$flag_tc_extreme)) |
                   (data$flag_tg_extreme & !is.na(data$flag_tg_extreme))
data$exclude_any[is.na(data$exclude_any)] = TRUE  # Exclude if can't determine

cat("\n--- EXCLUSION SUMMARY ---\n")
cat("Original sample:", nrow(data), "\n")
cat("Flagged for exclusion:", sum(data$exclude_any), "(", round(sum(data$exclude_any)/nrow(data)*100, 1), "%)\n")
cat("Clean sample:", sum(!data$exclude_any), "(", round(sum(!data$exclude_any)/nrow(data)*100, 1), "%)\n")

# ---------------------------------------------
# 4.6 CREATE ANALYSIS-READY DATASET
# ---------------------------------------------
cat("\n=== 4.6 FINAL ANALYSIS DATASET ===\n")

# Apply exclusions
data_clean = data[!data$exclude_any, ]

cat("Final analysis sample: n =", nrow(data_clean), "\n")
cat("\n--- FINAL DATASET SUMMARY ---\n")

# Summary of clean dataset
final_summary = data.frame(
  Variable = c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG"),
  N = sapply(data_clean[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")], 
             function(x) sum(!is.na(x))),
  Mean = round(sapply(data_clean[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")], 
                      mean, na.rm = TRUE), 2),
  SD = round(sapply(data_clean[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")], 
                    sd, na.rm = TRUE), 2),
  Min = round(sapply(data_clean[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")], 
                     min, na.rm = TRUE), 2),
  Max = round(sapply(data_clean[, c("d3kcal", "d3carbo", "d3fat", "d3protn", "TC", "HDL_C", "LDL_C", "TG")], 
                     max, na.rm = TRUE), 2)
)
print(final_summary, row.names = FALSE)

# Save clean dataset
cat("\n--- SAVING CLEAN DATASET ---\n")
saveRDS(data_clean, "data_clean.rds")
write.csv(data_clean, "data_clean.csv", row.names = FALSE)
cat("Saved: data_clean.rds and data_clean.csv\n")

# ---------------------------------------------
# 4.7 COMPARISON: ORIGINAL VS CLEAN DATASET
# ---------------------------------------------
cat("\n=== 4.7 ORIGINAL VS CLEAN COMPARISON ===\n")

comparison = data.frame(
  Metric = c("Sample Size", "Energy (mean)", "Energy (SD)", 
             "TC (mean)", "HDL-C (mean)", "LDL-C (mean)", "TG (mean)"),
  Original = c(
    nrow(data),
    round(mean(data$d3kcal, na.rm = TRUE), 1),
    round(sd(data$d3kcal, na.rm = TRUE), 1),
    round(mean(data$TC, na.rm = TRUE), 2),
    round(mean(data$HDL_C, na.rm = TRUE), 2),
    round(mean(data$LDL_C, na.rm = TRUE), 2),
    round(mean(data$TG, na.rm = TRUE), 2)
  ),
  Clean = c(
    nrow(data_clean),
    round(mean(data_clean$d3kcal, na.rm = TRUE), 1),
    round(sd(data_clean$d3kcal, na.rm = TRUE), 1),
    round(mean(data_clean$TC, na.rm = TRUE), 2),
    round(mean(data_clean$HDL_C, na.rm = TRUE), 2),
    round(mean(data_clean$LDL_C, na.rm = TRUE), 2),
    round(mean(data_clean$TG, na.rm = TRUE), 2)
  )
)
comparison$Change = paste0(round((as.numeric(comparison$Clean) - as.numeric(comparison$Original)) / 
                                   as.numeric(comparison$Original) * 100, 1), "%")
print(comparison, row.names = FALSE)

cat("\n##############################################\n")
cat("#  PHASE 4 COMPLETE - DATA QUALITY CHECKED  #\n")
cat("##############################################\n")

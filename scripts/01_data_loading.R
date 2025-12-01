# ============================================
# 01_data_loading.R - Data Loading and Initial Exploration
# ============================================

# ---------------------------------------------
# SETUP
# ---------------------------------------------

# Load setup script
source("scripts/00_setup.R")

message("\n=== PHASE 1: DATA LOADING ===\n")

# ---------------------------------------------
# LOAD RAW DATA
# ---------------------------------------------

# Load diet data
message("Loading diet data...")
diet_raw <- read.csv(file.path(PATHS$raw_data, "c12diet.csv"),
                     stringsAsFactors = FALSE)

# Load biomarker data
message("Loading biomarker data...")
biomarker_raw <- read.csv(file.path(PATHS$raw_data, "biomarker.csv"),
                          stringsAsFactors = FALSE)

# ---------------------------------------------
# INITIAL DATA VALIDATION
# ---------------------------------------------

cat("\n=== RAW DATA VALIDATION ===\n")

# Diet data structure
cat("\n--- DIET DATA STRUCTURE ---\n")
cat("Dimensions:", dim(diet_raw), "\n")
cat("Column names:\n")
print(names(diet_raw))
cat("\nData types:\n")
print(sapply(diet_raw, class))

# Biomarker data structure
cat("\n--- BIOMARKER DATA STRUCTURE ---\n")
cat("Dimensions:", dim(biomarker_raw), "\n")
cat("Column names:\n")
print(names(biomarker_raw))
cat("\nData types:\n")
print(sapply(biomarker_raw, class))

# ---------------------------------------------
# BASIC DATA QUALITY CHECKS
# ---------------------------------------------

cat("\n=== BASIC DATA QUALITY ===\n")

# Check for completely empty rows/columns
cat("\n--- EMPTY ROWS/COLUMNS ---\n")
diet_empty_rows <- sum(apply(diet_raw, 1, function(x) all(is.na(x) | x == "")))
biomarker_empty_rows <- sum(apply(biomarker_raw, 1, function(x) all(is.na(x) | x == "")))

cat("Diet data - Empty rows:", diet_empty_rows, "\n")
cat("Biomarker data - Empty rows:", biomarker_empty_rows, "\n")

# Check for duplicate IDs
cat("\n--- DUPLICATE ID ANALYSIS ---\n")
diet_duplicates <- sum(duplicated(diet_raw$IDind))
biomarker_duplicates <- sum(duplicated(biomarker_raw$IDind))

cat("Diet data duplicates (IDind):", diet_duplicates, "\n")
cat("Biomarker data duplicates (IDind):", biomarker_duplicates, "\n")

# Unique IDs
diet_unique_ids <- length(unique(diet_raw$IDind))
biomarker_unique_ids <- length(unique(biomarker_raw$IDind))

cat("Diet data unique IDs:", diet_unique_ids, "\n")
cat("Biomarker data unique IDs:", biomarker_unique_ids, "\n")

# ---------------------------------------------
# WAVE ANALYSIS
# ---------------------------------------------

cat("\n=== WAVE ANALYSIS ===\n")

# Diet waves
cat("\n--- DIET DATA WAVES ---\n")
diet_waves <- table(diet_raw$wave, useNA = "ifany")
print(diet_waves)
cat("Total waves in diet data:", length(diet_waves), "\n")

# Biomarker waves
cat("\n--- BIOMARKER DATA WAVES ---\n")
biomarker_waves <- table(biomarker_raw$wave, useNA = "ifany")
print(biomarker_waves)
cat("Total waves in biomarker data:", length(biomarker_waves), "\n")

# ---------------------------------------------
# ID OVERLAP ANALYSIS
# ---------------------------------------------

cat("\n=== ID OVERLAP ANALYSIS ===\n")

# Find common and unique IDs
common_ids <- intersect(diet_raw$IDind, biomarker_raw$IDind)
only_diet <- setdiff(diet_raw$IDind, biomarker_raw$IDind)
only_biomarker <- setdiff(biomarker_raw$IDind, diet_raw$IDind)

cat("Common IDs (in both datasets):", length(common_ids), "\n")
cat("Only in diet data:", length(only_diet), "\n")
cat("Only in biomarker data:", length(only_biomarker), "\n")
cat("Overlap percentage:", round(length(common_ids)/biomarker_unique_ids*100, 1), "%\n")

# ---------------------------------------------
# BASIC DESCRIPTIVE STATISTICS
# ---------------------------------------------

cat("\n=== BASIC DESCRIPTIVE STATISTICS ===\n")

# Diet data summary (key variables)
cat("\n--- DIET DATA SUMMARY ---\n")
diet_key_vars <- STUDY_PARAMS$macro_nutrients
diet_summary <- create_summary_table(diet_raw, diet_key_vars)
print(diet_summary, row.names = FALSE)

# Biomarker data summary (key variables)
cat("\n--- BIOMARKER DATA SUMMARY ---\n")
biomarker_key_vars <- STUDY_PARAMS$lipid_outcomes
biomarker_summary <- create_summary_table(biomarker_raw, biomarker_key_vars)
print(biomarker_summary, row.names = FALSE)

# ---------------------------------------------
# SAVE PROCESSED DATA
# ---------------------------------------------

cat("\n=== SAVING PROCESSED DATA ===\n")

# Save raw data with validation info
data_info <- list(
  diet_raw = diet_raw,
  biomarker_raw = biomarker_raw,
  validation = list(
    diet = list(
      dimensions = dim(diet_raw),
      duplicates = diet_duplicates,
      unique_ids = diet_unique_ids,
      waves = diet_waves
    ),
    biomarker = list(
      dimensions = dim(biomarker_raw),
      duplicates = biomarker_duplicates,
      unique_ids = biomarker_unique_ids,
      waves = biomarker_waves
    ),
    overlap = list(
      common_ids = length(common_ids),
      only_diet = length(only_diet),
      only_biomarker = length(only_biomarker)
    )
  )
)

# Save data and validation info
save_data(data_info, "01_data_loaded", formats = c("rds"))

message("\n=== PHASE 1 COMPLETE ===")
message("Data loaded and validated")
message("Saved: 01_data_loaded.rds")
message("Ready for Phase 2: Data Merging\n")
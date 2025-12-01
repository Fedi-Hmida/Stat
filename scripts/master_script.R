# ============================================
# master_script.R - Master Orchestration Script
# ============================================

# ============================================
# CHNS Dietary Patterns & Lipid Profiles Analysis
# Master Script - Runs All Phases
# ============================================

# ---------------------------------------------
# SETUP
# ---------------------------------------------

message("
========================================
🧬 CHNS DIETARY PATTERNS ANALYSIS 🧬
========================================
Master Script - Complete Pipeline
========================================
")

# ---------------------------------------------
# PHASE 0: SETUP
# ---------------------------------------------

message("\n📦 PHASE 0: SETUP")
message("Loading setup script and checking environment...")

tryCatch({
  source("scripts/00_setup.R")
  message("✓ Setup complete")
}, error = function(e) {
  stop("❌ Setup failed: ", e$message)
})

# ---------------------------------------------
# PHASE 1: DATA LOADING
# ---------------------------------------------

message("\n📊 PHASE 1: DATA LOADING")
message("Loading raw data and performing initial validation...")

tryCatch({
  source("scripts/01_data_loading.R")
  message("✓ Data loading complete")
}, error = function(e) {
  stop("❌ Data loading failed: ", e$message)
})

# ---------------------------------------------
# PHASE 2: DATA MERGING
# ---------------------------------------------

message("\n🔗 PHASE 2: DATA MERGING")
message("Analyzing merging strategies and wave alignment...")

tryCatch({
  source("scripts/02_data_merging.R")
  message("✓ Data merging complete")
}, error = function(e) {
  stop("❌ Data merging failed: ", e$message)
})

# ---------------------------------------------
# PHASE 3: DATA QUALITY
# ---------------------------------------------

message("\n🔍 PHASE 3: DATA QUALITY")
message("Comprehensive quality assessment and outlier detection...")

tryCatch({
  source("scripts/03_data_quality.R")
  message("✓ Data quality assessment complete")
}, error = function(e) {
  stop("❌ Data quality assessment failed: ", e$message)
})

# ---------------------------------------------
# PHASE 4: DATA CLEANING
# ---------------------------------------------

message("\n🧹 PHASE 4: DATA CLEANING")
message("Applying exclusions and creating final clean dataset...")

tryCatch({
  source("scripts/04_data_cleaning.R")
  message("✓ Data cleaning complete")
}, error = function(e) {
  stop("❌ Data cleaning failed: ", e$message)
})

# ---------------------------------------------
# NEXT STEPS
# ---------------------------------------------

message("
🚀 NEXT STEPS REQUIRED:
========================================
")

message("📋 IMMEDIATE NEXT STEPS:")
message("1. Obtain 19 individual food groups from CHNS")
message("2. Download demographic/covariate data")
message("3. Proceed to Phase 5: Descriptive Statistics")

message("
📁 CRITICAL FILES NEEDED:
• Individual dietary data (food-level consumption)
• Master/demographic file (age, sex, education, income)
• Anthropometric file (BMI, waist circumference)
• Physical activity data

📖 OBTAIN FROM:
China Health and Nutrition Survey (CHNS)
https://www.cpc.unc.edu/projects/china
")

message("
📊 UPCOMING PHASES (after obtaining food data):
• Phase 5: Descriptive Statistics
• Phase 6: Principal Component Analysis (PCA)
• Phase 7: Regression Analysis
• Phase 8: Results & Reporting
")

message("
========================================
🏁 PIPELINE READY FOR PHASE 5 🏁
========================================
")

# ---------------------------------------------
# CLEAN UP
# ---------------------------------------------

# Clear large objects from memory (optional)
# rm(list = c("data_info", "merge_results", "quality_results", "final_results"))

message("\nScript execution completed successfully!")
message("Check the 'data/processed/' directory for intermediate results.")
message("Final clean dataset: 'data_clean.rds'")
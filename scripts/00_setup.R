# ============================================
# 00_setup.R - Project Setup and Utilities
# ============================================

# ---------------------------------------------
# PROJECT SETUP
# ---------------------------------------------

# Clear workspace
rm(list = ls())

# Set working directory to project root
if (interactive() && requireNamespace("rstudioapi", quietly = TRUE)) {
  # Running in RStudio
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  # Running from command line or other environment
  # Assume script is run from project root, or find it
  script_dir <- getwd()
  if (!file.exists(file.path(script_dir, "scripts"))) {
    # Try to find project root by looking for scripts directory
    script_dir <- dirname(script_dir)
  }
  setwd(script_dir)
}

# ---------------------------------------------
# REQUIRED PACKAGES
# ---------------------------------------------

# Core packages
required_packages <- c(
  "dplyr",      # Data manipulation
  "tidyr",      # Data tidying
  "readr",      # Reading data
  "here",       # File paths
  "janitor",    # Data cleaning
  "skimr",      # Data summaries
  "naniar",     # Missing data visualization
  "psych",      # Psychological statistics (KMO, PCA)
  "corrplot",   # Correlation plots
  "ggplot2",    # Data visualization
  "ggpubr",     # Publication-ready plots
  "tableone",   # Descriptive statistics tables
  "finalfit",   # Statistical tables
  "broom",      # Tidy statistical outputs
  "car",        # Regression diagnostics
  "lmtest",     # Linear model tests
  "sandwich",   # Robust standard errors
  "stargazer",  # Regression tables
  "kableExtra", # Enhanced tables
  "writexl"     # Excel output
)

# Install missing packages
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(missing_packages)) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages, repos = "https://cran.rstudio.com/")
}

# Load all packages
invisible(lapply(required_packages, library, character.only = TRUE))

# ---------------------------------------------
# PROJECT CONSTANTS
# ---------------------------------------------

# File paths
PATHS <- list(
  raw_data = here::here("data", "raw"),
  processed_data = here::here("data", "processed"),
  scripts = here::here("scripts"),
  output = here::here("output"),
  tables = here::here("output", "tables"),
  figures = here::here("output", "figures")
)

# Study parameters
STUDY_PARAMS <- list(
  target_wave = 2009,
  original_sample_size = 2468,
  age_range = c(18, 80),
  lipid_outcomes = c("TC", "HDL_C", "LDL_C", "TG"),
  macro_nutrients = c("d3kcal", "d3carbo", "d3fat", "d3protn")
)

# ---------------------------------------------
# UTILITY FUNCTIONS
# ---------------------------------------------

#' Safe file saving with error handling
#' @param object R object to save
#' @param filename Filename without extension
#' @param path Directory path
#' @param formats Vector of formats to save (rds, csv, xlsx)
save_data <- function(object, filename, path = PATHS$processed_data,
                      formats = c("rds")) {

  if(!dir.exists(path)) dir.create(path, recursive = TRUE)

  for(format in formats) {
    filepath <- file.path(path, paste0(filename, ".", format))

    tryCatch({
      switch(format,
             "rds" = saveRDS(object, filepath),
             "csv" = write.csv(object, filepath, row.names = FALSE),
             "xlsx" = writexl::write_xlsx(object, filepath),
             stop("Unsupported format: ", format)
      )
      message("Saved: ", filepath)
    }, error = function(e) {
      warning("Failed to save ", filepath, ": ", e$message)
    })
  }
}

#' Safe file loading with error handling
#' @param filename Filename without extension
#' @param path Directory path
#' @param format File format (rds, csv)
load_data <- function(filename, path = PATHS$processed_data, format = "rds") {

  filepath <- file.path(path, paste0(filename, ".", format))

  if(!file.exists(filepath)) {
    stop("File not found: ", filepath)
  }

  tryCatch({
    switch(format,
           "rds" = readRDS(filepath),
           "csv" = read.csv(filepath, stringsAsFactors = FALSE),
           stop("Unsupported format: ", format)
    )
  }, error = function(e) {
    stop("Failed to load ", filepath, ": ", e$message)
  })
}

#' Create publication-ready summary table
#' @param data Data frame
#' @param vars Variables to summarize
#' @param group Optional grouping variable
create_summary_table <- function(data, vars, group = NULL) {

  if(is.null(group)) {
    # Overall summary
    summary_stats <- data.frame(
      Variable = vars,
      N = sapply(data[vars], function(x) sum(!is.na(x))),
      Mean = round(sapply(data[vars], mean, na.rm = TRUE), 2),
      SD = round(sapply(data[vars], sd, na.rm = TRUE), 2),
      Median = round(sapply(data[vars], median, na.rm = TRUE), 2),
      Min = round(sapply(data[vars], min, na.rm = TRUE), 2),
      Max = round(sapply(data[vars], max, na.rm = TRUE), 2)
    )
  } else {
    # Grouped summary
    summary_stats <- data %>%
      group_by(.data[[group]]) %>%
      summarise(across(all_of(vars),
                      list(N = ~sum(!is.na(.)),
                           Mean = ~round(mean(., na.rm = TRUE), 2),
                           SD = ~round(sd(., na.rm = TRUE), 2),
                           Median = ~round(median(., na.rm = TRUE), 2)),
                      .names = "{.col}_{.fn}"))
  }

  return(summary_stats)
}

#' Enhanced outlier detection
#' @param x Numeric vector
#' @param method Method: "iqr" or "zscore"
#' @param threshold Threshold for detection
detect_outliers <- function(x, method = "iqr", threshold = 1.5) {

  x_clean <- x[!is.na(x)]

  if(method == "iqr") {
    q1 <- quantile(x_clean, 0.25)
    q3 <- quantile(x_clean, 0.75)
    iqr <- q3 - q1
    lower <- q1 - threshold * iqr
    upper <- q3 + threshold * iqr

    outliers <- x < lower | x > upper

  } else if(method == "zscore") {
    z_scores <- (x_clean - mean(x_clean)) / sd(x_clean)
    outliers <- abs(z_scores) > threshold

  } else {
    stop("Method must be 'iqr' or 'zscore'")
  }

  return(list(
    outliers = outliers,
    n_outliers = sum(outliers, na.rm = TRUE),
    pct_outliers = round(sum(outliers, na.rm = TRUE) / length(x) * 100, 2),
    bounds = if(method == "iqr") c(lower, upper) else NULL
  ))
}

#' Calculate skewness
#' @param x Numeric vector
calc_skewness <- function(x) {
  x <- x[!is.na(x)]
  n <- length(x)
  if(n < 3) return(NA)

  mean_x <- mean(x)
  sd_x <- sd(x)
  skew <- (sum((x - mean_x)^3) / n) / (sd_x^3)
  return(round(skew, 3))
}

# ---------------------------------------------
# SESSION INFO
# ---------------------------------------------

message("\n=== PROJECT SETUP COMPLETE ===")
message("Working directory: ", getwd())
message("R version: ", R.version$version.string)
message("Date: ", format(Sys.Date(), "%Y-%m-%d"))
message("Loaded packages: ", paste(required_packages, collapse = ", "))
message("Project paths configured")
message("Utility functions loaded")
message("Ready for analysis!\n")

# Clean up
rm(required_packages, missing_packages)
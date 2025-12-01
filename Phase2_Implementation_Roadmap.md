# 📋 PHASE 2: IMPLEMENTATION ROADMAP

## Dietary Patterns and Blood Lipid Profiles Analysis
### Replication of Zhang et al. (2016) in R/RStudio

---

## 📌 Project Overview

| Attribute | Details |
|-----------|---------|
| **Original Paper** | Zhang et al. (2016) "Association between dietary patterns and blood lipid profiles among Chinese women" |
| **Journal** | Public Health Nutrition, 19(18), 3361-3368 |
| **Original Software** | SAS 9.2 |
| **Target Software** | R/RStudio |
| **Data Source** | China Health and Nutrition Survey (CHNS) 2009 |
| **Sample Size** | n = 2,468 women aged 18-80 years |

---

## 🔧 Required R Packages

### Core Analysis Packages

```r
# Data Manipulation & Visualization
install.packages("tidyverse")      # dplyr, ggplot2, tidyr, readr
install.packages("data.table")     # Fast data manipulation

# Principal Component Analysis
install.packages("psych")          # principal() function with rotation
install.packages("factoextra")     # PCA visualization (scree plots, biplots)
install.packages("FactoMineR")     # Alternative PCA implementation

# Statistical Analysis
install.packages("car")            # ANCOVA, VIF diagnostics
install.packages("broom")          # Tidy regression outputs
install.packages("lmtest")         # Regression diagnostics
install.packages("sandwich")       # Robust standard errors

# Table Generation
install.packages("tableone")       # Descriptive statistics tables
install.packages("gtsummary")      # Publication-ready tables
install.packages("kableExtra")     # Enhanced table formatting
install.packages("flextable")      # Word/PowerPoint compatible tables

# Reporting
install.packages("rmarkdown")      # Dynamic documents
install.packages("knitr")          # Report generation
```

### Package Loading Script

```r
# Load all required packages
library(tidyverse)
library(psych)
library(factoextra)
library(FactoMineR)
library(car)
library(broom)
library(tableone)
library(gtsummary)
library(kableExtra)
```

---

## 📊 Data Requirements Specification

### Required Variables for Full Replication

#### 1. Dietary Intake Data (19 Food Groups)

| Food Group | Variable Name | Unit | Description |
|------------|---------------|------|-------------|
| Rice | `rice` | g/d | Average 3-day intake |
| Wheat | `wheat` | g/d | Wheat flour products |
| Other cereals | `other_cereals` | g/d | Coarse grains |
| Tubers | `tubers` | g/d | Potatoes, sweet potatoes |
| Legumes | `legumes` | g/d | Beans, soy products |
| Fungi and algae | `fungi_algae` | g/d | Mushrooms, seaweed |
| Vegetables | `vegetables` | g/d | All vegetables |
| Fruits | `fruits` | g/d | Fresh fruits |
| Pork | `pork` | g/d | Pork meat |
| Other livestock | `other_livestock` | g/d | Beef, lamb, etc. |
| Poultry | `poultry` | g/d | Chicken, duck |
| Organ meats | `organ_meats` | g/d | Liver, kidney, etc. |
| Aquatic products | `aquatic` | g/d | Fish, shrimp, shellfish |
| Milk | `milk` | g/d | Dairy products |
| Eggs | `eggs` | g/d | Eggs |
| Nuts | `nuts` | g/d | Nuts and seeds |
| Cakes | `cakes` | g/d | Pastries, cookies |
| Fast foods | `fast_foods` | g/d | Western fast food |
| Soft drinks | `soft_drinks` | g/d | Sugary beverages |

#### 2. Biomarker Data (Lipid Profiles)

| Variable | Description | Unit | Source File |
|----------|-------------|------|-------------|
| `TC` | Total Cholesterol | mg/dl | biomarker.csv ✅ |
| `HDL_C` | HDL Cholesterol | mg/dl | biomarker.csv ✅ |
| `LDL_C` | LDL Cholesterol | mg/dl | biomarker.csv ✅ |
| `TG` | Triglycerides (TAG) | mg/dl | biomarker.csv ✅ |

#### 3. Covariate Data

| Variable | Type | Categories/Unit | Status |
|----------|------|-----------------|--------|
| `age` | Categorical | 18-44, 45-59, 60-80 years | ❌ Missing |
| `education` | Categorical | Low, Medium, High | ❌ Missing |
| `urban_rural` | Binary | Urban=1, Rural=0 | ❌ Missing |
| `smoking` | Binary | Yes=1, No=0 | ❌ Missing |
| `drinking` | Binary | Yes=1, No=0 | ❌ Missing |
| `physical_activity` | Continuous | MET-hours/week | ❌ Missing |
| `income` | Continuous | Annual household income | ❌ Missing |
| `BMI` | Continuous | kg/m² | ❌ Missing |
| `waist` | Continuous | cm | ❌ Missing |
| `energy_intake` | Continuous | kcal/d | ⚠️ Partial (d3kcal) |

#### 4. Nutrient Data (for Table 3)

| Nutrient | Unit | Required for |
|----------|------|--------------|
| Total energy | kcal/d, kJ/d | Adjustment |
| Carbohydrate | % energy | Comparison |
| Protein | % energy | Comparison |
| Fat | % energy | Comparison |
| Fibre | g/d | Comparison |
| Vitamin C | mg/d | Comparison |
| Vitamin A | μg RE/d | Comparison |
| Calcium | mg/d | Comparison |
| Iron | mg/d | Comparison |

---

## 📁 Project Structure

```
Face/
├── 📄 article.tex                    # Original paper (reference)
├── 📄 biomarker.csv                  # Lipid outcome data
├── 📄 c12diet.csv                    # Dietary data (incomplete)
│
├── 📁 R_Scripts/
│   ├── 00_setup.R                    # Package installation & loading
│   ├── 01_data_import.R              # Data loading & initial cleaning
│   ├── 02_data_cleaning.R            # Missing values, transformations
│   ├── 03_eda.R                      # Exploratory data analysis
│   ├── 04_pca_analysis.R             # Principal Component Analysis
│   ├── 05_pattern_scores.R           # Factor scores & quartiles
│   ├── 06_descriptive_tables.R       # Tables 1-3 generation
│   ├── 07_regression_analysis.R      # Table 4 multivariate models
│   ├── 08_diagnostics.R              # Model validation
│   ├── 09_sensitivity.R              # Sensitivity analyses
│   └── 10_final_report.Rmd           # R Markdown report
│
├── 📁 Data/
│   ├── raw/                          # Original unmodified data
│   ├── processed/                    # Cleaned analysis-ready data
│   └── derived/                      # Pattern scores, merged data
│
├── 📁 Output/
│   ├── tables/                       # Publication tables (HTML, Word)
│   ├── figures/                      # Scree plots, biplots, etc.
│   └── reports/                      # Final analysis reports
│
├── 📁 Documentation/
│   ├── Phase1_Deep_Analysis.md
│   ├── Phase2_Implementation_Roadmap.md
│   ├── Phase3_Environment_Setup.md
│   ├── Phase4_Data_Import.md
│   ├── Phase5_EDA.md
│   ├── Phase6_PCA_Implementation.md
│   ├── Phase7_Pattern_Scores.md
│   ├── Phase8_Descriptive_Stats.md
│   ├── Phase9_Regression_Analysis.md
│   └── Phase10_Validation_Report.md
│
└── 📄 README.md                      # Project overview
```

---

## 🗓️ 10-Phase Implementation Plan

---

### **PHASE 1: Deep Analysis** ✅ COMPLETED

**Objective:** Understand the research methodology and identify data requirements

**Deliverables:**
- [x] Research objectives identified
- [x] Methodology summary created
- [x] Data gap analysis performed
- [x] Statistical tests mapped
- [x] Expected outputs defined

**Key Findings:**
- 19 food groups required for PCA (NOT available in current data)
- Wave mismatch identified (biomarker=2009, dietary=2011)
- Covariate data missing from provided files

---

### **PHASE 2: Environment Setup**

**Objective:** Configure R/RStudio with all required packages and project structure

**Tasks:**
| Task | Tool/Command | Priority |
|------|--------------|----------|
| Create R Project | RStudio → New Project | High |
| Install packages | `install.packages()` | High |
| Create folder structure | `dir.create()` | Medium |
| Set up .Rprofile | Custom settings | Low |
| Configure Git (optional) | `usethis::use_git()` | Low |

**R Script: `00_setup.R`**

```r
# ============================================
# 00_setup.R - Environment Setup
# Project: Dietary Patterns & Lipid Profiles
# ============================================

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Required packages list
packages <- c(
  # Data manipulation
  "tidyverse", "data.table", "janitor",
  # PCA & Factor Analysis
  "psych", "factoextra", "FactoMineR",
  # Statistical analysis
  "car", "broom", "lmtest", "sandwich",
  # Tables
  "tableone", "gtsummary", "kableExtra", "flextable",
  # Reporting
  "rmarkdown", "knitr"
)

# Install missing packages
install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}
sapply(packages, install_if_missing)

# Load all packages
lapply(packages, library, character.only = TRUE)

# Create project folders
dirs <- c("R_Scripts", "Data/raw", "Data/processed", "Data/derived",
          "Output/tables", "Output/figures", "Output/reports", "Documentation")
sapply(dirs, dir.create, recursive = TRUE, showWarnings = FALSE)

# Session info
sessionInfo()
```

**Validation Checklist:**
- [ ] All packages installed without errors
- [ ] Folder structure created
- [ ] R version ≥ 4.0.0 confirmed

---

### **PHASE 3: Data Import & Cleaning**

**Objective:** Load all data files, handle missing values, and merge datasets

**Tasks:**
| Task | Function | Details |
|------|----------|---------|
| Import biomarker.csv | `read_csv()` | 48 columns, wave=2009 |
| Import c12diet.csv | `read_csv()` | 14 columns, wave=2011 |
| Import food group data | `read_csv()` | **PENDING - Need data** |
| Handle missing values | `na.omit()` / imputation | Document missingness |
| Merge datasets | `left_join()` by IDind | Validate merge |
| Filter sample | `filter()` | Women, 18-80 years |

**R Script: `01_data_import.R`**

```r
# ============================================
# 01_data_import.R - Data Import
# ============================================

library(tidyverse)
library(janitor)

# Set working directory to project root
# setwd("C:/Users/Fedih/Downloads/Face")

# ----- Import Biomarker Data -----
biomarker <- read_csv("biomarker.csv") %>%
  clean_names() %>%
  filter(wave == 2009) %>%
  select(idind, wave, 
         tc = tc, hdl_c, ldl_c, tg,
         tc_mg, hdl_c_mg, ldl_c_mg, tg_mg)

cat("Biomarker data: ", nrow(biomarker), "observations\n")

# ----- Import Dietary Data -----
diet <- read_csv("c12diet.csv") %>%
  clean_names()

cat("Dietary data: ", nrow(diet), "observations\n")

# ----- Check ID overlap -----
common_ids <- intersect(biomarker$idind, diet$idind)
cat("Common IDs: ", length(common_ids), "\n")

# ----- Merge datasets -----
# NOTE: Wave mismatch - may need adjustment
merged_data <- biomarker %>%
  inner_join(diet, by = "idind", suffix = c("_bio", "_diet"))

# ----- Summary -----
glimpse(merged_data)
summary(merged_data)

# ----- Save processed data -----
write_csv(merged_data, "Data/processed/merged_data.csv")
```

**Data Quality Checks:**
- [ ] Missing values documented
- [ ] ID variable consistency verified
- [ ] Outliers identified
- [ ] Data types correct

---

### **PHASE 4: Exploratory Data Analysis (EDA)**

**Objective:** Understand data distributions, correlations, and identify patterns

**Tasks:**
| Analysis | Function | Output |
|----------|----------|--------|
| Summary statistics | `summary()`, `describe()` | Console/table |
| Distribution plots | `ggplot() + geom_histogram()` | Histograms |
| Correlation matrix | `cor()`, `corrplot()` | Heatmap |
| Box plots by groups | `ggplot() + geom_boxplot()` | Boxplots |
| Missing data pattern | `naniar::vis_miss()` | Visualization |

**R Script: `03_eda.R`**

```r
# ============================================
# 03_eda.R - Exploratory Data Analysis
# ============================================

library(tidyverse)
library(psych)
library(corrplot)
library(naniar)

# Load processed data
data <- read_csv("Data/processed/merged_data.csv")

# ----- 1. Summary Statistics -----
describe(data)

# ----- 2. Lipid Outcome Distributions -----
lipids <- c("tc_mg", "hdl_c_mg", "ldl_c_mg", "tg_mg")

data %>%
  select(all_of(lipids)) %>%
  pivot_longer(everything(), names_to = "lipid", values_to = "value") %>%
  ggplot(aes(x = value)) +
  geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7) +
  facet_wrap(~lipid, scales = "free") +
  labs(title = "Distribution of Lipid Outcomes",
       x = "Concentration (mg/dl)", y = "Count") +
  theme_minimal()

ggsave("Output/figures/lipid_distributions.png", width = 10, height = 8)

# ----- 3. Correlation Matrix (Food Groups) -----
# NOTE: Requires 19 food group variables
# food_groups <- data %>% select(rice:soft_drinks)
# cor_matrix <- cor(food_groups, use = "pairwise.complete.obs")
# corrplot(cor_matrix, method = "color", type = "upper")

# ----- 4. Missing Data Pattern -----
vis_miss(data)
ggsave("Output/figures/missing_data_pattern.png", width = 10, height = 6)

# ----- 5. Outlier Detection -----
data %>%
  select(all_of(lipids)) %>%
  pivot_longer(everything()) %>%
  ggplot(aes(x = name, y = value)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Outlier Detection - Lipid Profiles") +
  theme_minimal()

ggsave("Output/figures/lipid_outliers.png", width = 8, height = 6)
```

**EDA Deliverables:**
- [ ] Summary statistics table
- [ ] Distribution plots for all key variables
- [ ] Correlation heatmap for food groups
- [ ] Missing data visualization
- [ ] Outlier identification report

---

### **PHASE 5: PCA Implementation**

**Objective:** Extract dietary patterns using Principal Component Analysis with varimax rotation

**Methodology Specifications (from paper):**
| Parameter | Value |
|-----------|-------|
| Input | 19 food group means (g/d) |
| Rotation | Orthogonal (varimax) |
| Factor retention | Eigenvalue > 1 |
| Loading threshold | ≥ 0.25 (absolute) |
| Factors extracted | 3 |
| Variance explained | 26.2% total |

**R Script: `04_pca_analysis.R`**

```r
# ============================================
# 04_pca_analysis.R - Principal Component Analysis
# ============================================

library(tidyverse)
library(psych)
library(factoextra)

# Load data with 19 food groups
# NOTE: This requires the complete food group data
data <- read_csv("Data/processed/analysis_data.csv")

# ----- Define food groups -----
food_groups <- c("rice", "wheat", "other_cereals", "tubers", "legumes",
                 "fungi_algae", "vegetables", "fruits", "pork", 
                 "other_livestock", "poultry", "organ_meats", "aquatic",
                 "milk", "eggs", "nuts", "cakes", "fast_foods", "soft_drinks")

# ----- Extract food group matrix -----
food_matrix <- data %>%
  select(all_of(food_groups)) %>%
  as.matrix()

# ----- Check for adequacy -----
# Kaiser-Meyer-Olkin (KMO) measure
KMO(food_matrix)

# Bartlett's test of sphericity
cortest.bartlett(food_matrix)

# ----- Perform PCA with Varimax Rotation -----
pca_result <- principal(food_matrix, 
                         nfactors = 3,      # Extract 3 factors
                         rotate = "varimax", # Orthogonal rotation
                         scores = TRUE)      # Calculate factor scores

# ----- Display results -----
print(pca_result, cut = 0.25, sort = TRUE)

# ----- Scree Plot -----
scree(food_matrix, factors = TRUE, pc = TRUE)

# Alternative using factoextra
pca_prcomp <- prcomp(food_matrix, scale. = TRUE)
fviz_eig(pca_prcomp, addlabels = TRUE, ylim = c(0, 15)) +
  labs(title = "Scree Plot - Eigenvalues",
       x = "Principal Component", y = "Percentage of Variance")

ggsave("Output/figures/scree_plot.png", width = 8, height = 6)

# ----- Extract Factor Loadings -----
loadings_df <- as.data.frame(unclass(pca_result$loadings)) %>%
  rownames_to_column("Food") %>%
  rename(Traditional_Southern = RC1,
         Snack = RC2,
         Western = RC3)

# Apply threshold (show only loadings ≥ 0.25)
loadings_table <- loadings_df %>%
  mutate(across(c(Traditional_Southern, Snack, Western), 
                ~ifelse(abs(.) >= 0.25, round(., 2), NA)))

print(loadings_table)

# ----- Variance Explained -----
variance_explained <- pca_result$Vaccounted
print(variance_explained)

# Expected: Traditional Southern = 11.1%, Snack = 8.8%, Western = 6.3%

# ----- Save Results -----
write_csv(loadings_table, "Output/tables/factor_loadings.csv")
saveRDS(pca_result, "Data/derived/pca_result.rds")
```

**Validation Against Paper:**
| Pattern | Expected Variance | Calculated | Match |
|---------|-------------------|------------|-------|
| Traditional Southern | 11.1% | — | ⬜ |
| Snack | 8.8% | — | ⬜ |
| Western | 6.3% | — | ⬜ |
| **Total** | **26.2%** | — | ⬜ |

---

### **PHASE 6: Pattern Score Calculation**

**Objective:** Calculate individual factor scores and create quartile categories

**R Script: `05_pattern_scores.R`**

```r
# ============================================
# 05_pattern_scores.R - Factor Scores & Quartiles
# ============================================

library(tidyverse)

# Load PCA results
pca_result <- readRDS("Data/derived/pca_result.rds")
data <- read_csv("Data/processed/analysis_data.csv")

# ----- Extract Factor Scores -----
# Scores are weighted sums of standardized food intakes
factor_scores <- as.data.frame(pca_result$scores) %>%
  rename(score_traditional = RC1,
         score_snack = RC2,
         score_western = RC3)

# ----- Add scores to data -----
data_with_scores <- bind_cols(data, factor_scores)

# ----- Create Quartiles -----
data_with_scores <- data_with_scores %>%
  mutate(
    Q_traditional = ntile(score_traditional, 4),
    Q_snack = ntile(score_snack, 4),
    Q_western = ntile(score_western, 4)
  )

# ----- Verify quartile distribution -----
table(data_with_scores$Q_traditional)
table(data_with_scores$Q_snack)
table(data_with_scores$Q_western)

# ----- Summary by quartiles -----
data_with_scores %>%
  group_by(Q_traditional) %>%
  summarise(
    n = n(),
    mean_score = mean(score_traditional),
    sd_score = sd(score_traditional)
  )

# ----- Save -----
write_csv(data_with_scores, "Data/derived/data_with_pattern_scores.csv")
```

---

### **PHASE 7: Descriptive Statistics (Tables 1-3)**

**Objective:** Generate Tables 1, 2, and 3 from the paper

**R Script: `06_descriptive_tables.R`**

```r
# ============================================
# 06_descriptive_tables.R - Descriptive Tables
# ============================================

library(tidyverse)
library(tableone)
library(gtsummary)
library(kableExtra)

data <- read_csv("Data/derived/data_with_pattern_scores.csv")

# ===== TABLE 1: Factor Loadings =====
# Already created in Phase 5
loadings <- read_csv("Output/tables/factor_loadings.csv")

loadings %>%
  kbl(caption = "Table 1. Factor-loading matrix for dietary patterns") %>%
  kable_styling(bootstrap_options = c("striped", "hover")) %>%
  save_kable("Output/tables/Table1_Factor_Loadings.html")

# ===== TABLE 2: Participant Characteristics by Quartiles =====

# Define variables for Table 2
vars <- c("age", "urban", "education_high", "current_smoker", 
          "current_drinker", "bmi", "waist", "hdl_c_mg", 
          "ldl_c_mg", "tg_mg", "tc_mg")

cat_vars <- c("urban", "education_high", "current_smoker", "current_drinker")

# Function to create Table 2 for each pattern
create_table2 <- function(data, pattern_var) {
  CreateTableOne(vars = vars, 
                 strata = pattern_var,
                 data = data,
                 factorVars = cat_vars,
                 test = TRUE) %>%
    print(showAllLevels = TRUE, quote = FALSE, noSpaces = TRUE)
}

# Traditional Southern Q1 vs Q4
table2_traditional <- data %>%
  filter(Q_traditional %in% c(1, 4)) %>%
  create_table2("Q_traditional")

# Save Table 2
# write.csv(table2_traditional, "Output/tables/Table2_Characteristics.csv")

# ===== TABLE 3: Nutrient Intakes by Quartiles =====

nutrients <- c("energy_kcal", "pct_carb", "pct_protein", "pct_fat",
               "fibre", "vitamin_c", "vitamin_a", "calcium", "iron")

# ANCOVA for age and energy adjustment
# Example for one nutrient
model <- aov(vitamin_c ~ Q_traditional + age + energy_kcal, data = data)
summary(model)

# Create adjusted means using emmeans
library(emmeans)
emmeans(model, "Q_traditional")

# Generate full Table 3
# ... (detailed implementation)
```

---

### **PHASE 8: Regression Analysis (Table 4)**

**Objective:** Multivariate linear regression for dietary pattern-lipid associations

**Model Specification:**
```
Lipid Outcome = β₀ + β₁(Pattern Score) + β₂(Age) + β₃(Education) + 
                β₄(Urban) + β₅(Smoking) + β₆(Drinking) + β₇(Physical Activity) +
                β₈(Income) + β₉(BMI) + β₁₀(Energy Intake) + ε
```

**R Script: `07_regression_analysis.R`**

```r
# ============================================
# 07_regression_analysis.R - Multivariate Regression
# ============================================

library(tidyverse)
library(broom)
library(gtsummary)

data <- read_csv("Data/derived/data_with_pattern_scores.csv")

# ----- Define covariates -----
covariates <- c("age_cat", "education", "urban", "smoking", 
                "drinking", "physical_activity", "income", 
                "bmi", "energy_kcal")

# ----- Model 1: Continuous Pattern Scores -----

# HDL-C ~ Traditional Southern
model_hdl_trad <- lm(hdl_c_mg ~ score_traditional + age_cat + education + 
                      urban + smoking + drinking + physical_activity + 
                      income + bmi + energy_kcal, data = data)

summary(model_hdl_trad)
confint(model_hdl_trad)

# Extract beta and CI for pattern score
tidy(model_hdl_trad, conf.int = TRUE) %>%
  filter(term == "score_traditional")
# Expected: β = -0.68, 95% CI: -1.22, -0.14

# ----- All lipid outcomes for all patterns -----
outcomes <- c("tc_mg", "hdl_c_mg", "ldl_c_mg", "tg_mg")
patterns <- c("score_traditional", "score_snack", "score_western")

# Function to run regression
run_regression <- function(outcome, pattern, data) {
  formula <- as.formula(paste(outcome, "~", pattern, 
                               "+ age_cat + education + urban + smoking +",
                               "drinking + physical_activity + income + bmi + energy_kcal"))
  model <- lm(formula, data = data)
  
  tidy(model, conf.int = TRUE) %>%
    filter(term == pattern) %>%
    mutate(outcome = outcome, pattern = pattern)
}

# Run all combinations
results_continuous <- expand_grid(outcome = outcomes, pattern = patterns) %>%
  pmap_dfr(~run_regression(..1, ..2, data))

print(results_continuous)

# ----- Model 2: Quartile Categories -----

# Convert quartiles to factors with Q1 as reference
data <- data %>%
  mutate(
    Q_traditional = factor(Q_traditional, levels = 1:4),
    Q_snack = factor(Q_snack, levels = 1:4),
    Q_western = factor(Q_western, levels = 1:4)
  )

# HDL-C ~ Traditional Southern Quartiles
model_hdl_trad_q <- lm(hdl_c_mg ~ Q_traditional + age_cat + education + 
                        urban + smoking + drinking + physical_activity + 
                        income + bmi + energy_kcal, data = data)

summary(model_hdl_trad_q)
# Expected Q4 vs Q1: β = -1.86, 95% CI: -3.39, -0.33

# ----- P for trend -----
# Use numeric quartile in model
data$Q_trad_num <- as.numeric(data$Q_traditional)
model_trend <- lm(hdl_c_mg ~ Q_trad_num + covariates..., data = data)
summary(model_trend)$coefficients["Q_trad_num", "Pr(>|t|)"]

# ----- Generate Table 4 -----
# Combine all results into publication table
table4 <- results_continuous %>%
  mutate(
    beta_ci = paste0(round(estimate, 2), " (", 
                     round(conf.low, 2), ", ", 
                     round(conf.high, 2), ")"),
    sig = case_when(
      p.value < 0.01 ~ "**",
      p.value < 0.05 ~ "*",
      TRUE ~ ""
    )
  ) %>%
  select(pattern, outcome, beta_ci, sig)

# Save Table 4
write_csv(table4, "Output/tables/Table4_Regression_Results.csv")
```

**Expected Results Validation:**

| Pattern | Outcome | Expected β | Expected 95% CI | Significance |
|---------|---------|------------|-----------------|--------------|
| Traditional | HDL-C | -0.68 | -1.22, -0.14 | * |
| Snack | TAG | 4.14 | 0.44, 7.84 | * |
| Western | TC | 2.52 | 1.03, 4.02 | ** |
| Western | LDL-C | 2.26 | 0.86, 3.66 | ** |

---

### **PHASE 9: Validation & Diagnostics**

**Objective:** Verify model assumptions and perform sensitivity analyses

**R Script: `08_diagnostics.R`**

```r
# ============================================
# 08_diagnostics.R - Model Diagnostics
# ============================================

library(tidyverse)
library(car)
library(lmtest)

# Load final model
model <- readRDS("Data/derived/final_model.rds")

# ----- 1. Linearity Check -----
plot(model, which = 1)  # Residuals vs Fitted

# ----- 2. Normality of Residuals -----
plot(model, which = 2)  # Q-Q plot
shapiro.test(residuals(model))

# ----- 3. Homoscedasticity -----
plot(model, which = 3)  # Scale-Location
bptest(model)  # Breusch-Pagan test

# ----- 4. Multicollinearity -----
vif(model)
# All VIF should be < 5 (ideally < 3)

# ----- 5. Influential Observations -----
plot(model, which = 4)  # Cook's distance
influencePlot(model)

# ----- 6. Independence -----
dwtest(model)  # Durbin-Watson test

# ----- Save diagnostic plots -----
png("Output/figures/model_diagnostics.png", width = 1200, height = 1000)
par(mfrow = c(2, 2))
plot(model)
dev.off()
```

**Sensitivity Analyses:**
- [ ] Exclude outliers (Cook's D > 4/n)
- [ ] Stratify by age groups
- [ ] Stratify by urban/rural
- [ ] Alternative covariate adjustment
- [ ] Bootstrap confidence intervals

---

### **PHASE 10: Documentation & Reporting**

**Objective:** Create final documentation and reproducible reports

**Deliverables:**

| Document | Format | Purpose |
|----------|--------|---------|
| Phase1_Deep_Analysis.md | Markdown | Research methodology summary |
| Phase2_Implementation_Roadmap.md | Markdown | This document |
| Phase3_Environment_Setup.md | Markdown | Setup instructions |
| Phase4_Data_Import.md | Markdown | Data loading documentation |
| Phase5_EDA.md | Markdown | Exploratory analysis report |
| Phase6_PCA_Implementation.md | Markdown | PCA methodology & results |
| Phase7_Pattern_Scores.md | Markdown | Score calculation methods |
| Phase8_Descriptive_Stats.md | Markdown | Tables 1-3 generation |
| Phase9_Regression_Analysis.md | Markdown | Table 4 & interpretation |
| Phase10_Validation_Report.md | Markdown | Diagnostics & conclusions |
| Final_Report.Rmd | R Markdown | Complete reproducible report |
| Final_Report.html/pdf | HTML/PDF | Publication-ready output |

**R Markdown Report Template:**

```r
# ============================================
# 10_final_report.Rmd
# ============================================

---
title: "Dietary Patterns and Blood Lipid Profiles Among Chinese Women"
subtitle: "Replication of Zhang et al. (2016)"
author: "Analysis Team"
date: "`r Sys.Date()`"
output:
  html_document:
    toc: true
    toc_float: true
    theme: flatly
    code_folding: hide
---

# {.tabset}

## Abstract

## Methods

### Study Population

### Dietary Pattern Analysis

### Statistical Analysis

## Results

### Table 1: Factor Loadings

### Table 2: Participant Characteristics

### Table 3: Nutrient Intakes

### Table 4: Regression Results

## Discussion

## Conclusions

## References
```

---

## ⚠️ CRITICAL DATA GAPS TO RESOLVE

Before implementation can proceed, the following data must be obtained:

### 1. 19 Food Group Intake Data (CRITICAL)
**Status:** ❌ NOT AVAILABLE  
**Required for:** PCA analysis (core methodology)  
**Source:** CHNS dietary recall data with food-level detail  
**Variables needed:** Daily intake (g/d) for each of 19 food groups

### 2. Wave Year Alignment
**Status:** ⚠️ MISMATCH  
**Issue:** biomarker.csv = 2009, c12diet.csv = 2011  
**Resolution:** Obtain 2009 dietary data OR justify using 2011

### 3. Covariate Data
**Status:** ❌ NOT AVAILABLE  
**Required variables:**
- Demographics: age, education, urban/rural
- Lifestyle: smoking, drinking, physical activity
- Anthropometric: BMI, waist circumference
- Economic: household income

### 4. Complete Nutrient Data
**Status:** ⚠️ PARTIAL  
**Available:** energy, carbohydrate, fat, protein  
**Missing:** fibre, vitamins (A, C), minerals (Ca, Fe)

---

## 📞 Next Steps

1. **User Action Required:** Provide additional CHNS data files containing:
   - 19 food group intake variables
   - Demographic and lifestyle covariates
   - 2009 wave dietary data (or confirm 2011 is acceptable)

2. **Upon Data Receipt:** Proceed with Phase 3 (Data Import) and continue through all phases

3. **Alternative Approach:** If full data unavailable, discuss modified analysis options:
   - Use macronutrients instead of food groups
   - Simplified covariate adjustment
   - Document limitations

---

## 📚 References

1. Zhang JG, Wang ZH, Wang HJ, et al. (2016). Association between dietary patterns and blood lipid profiles among Chinese women. *Public Health Nutrition*, 19(18), 3361-3368.

2. Popkin BM, Du S, Zhai F, Zhang B. (2010). Cohort Profile: The China Health and Nutrition Survey. *International Journal of Epidemiology*, 39(6), 1435-1440.

3. R Core Team (2024). R: A language and environment for statistical computing. R Foundation for Statistical Computing, Vienna, Austria.

---

*Document created: Phase 2 Implementation Roadmap*  
*Last updated: `r Sys.Date()`*  
*Status: PENDING DATA RESOLUTION*

# 📋 PHASE 3: Data Import & Cleaning

## Dietary Patterns and Blood Lipid Profiles Analysis
### Detailed Documentation - No Code

---

## 🎯 Phase Objective

Transform raw data files into a clean, analysis-ready dataset that can be used for Principal Component Analysis (PCA) and subsequent regression modeling.

---

## ❓ Why Merge Datasets?

### The Research Question Requires Linked Data

The study investigates: **"How do dietary patterns associate with blood lipid profiles?"**

This question inherently requires TWO types of information for **the same individual**:

| Data Type | Source | What It Contains |
|-----------|--------|------------------|
| **Exposure** (X) | Dietary data | What foods each person eats |
| **Outcome** (Y) | Biomarker data | Each person's blood lipid levels |

### Without Merging:
- You have dietary information for Person A
- You have lipid levels for Person A
- But they are in **separate files**
- You cannot analyze the relationship between diet and lipids

### With Merging:
- One row per person
- Each row contains BOTH diet AND lipid data
- Now you can ask: "Does Person A's diet predict Person A's lipid levels?"

---

## 🔗 The Merging Logic

### Step-by-Step Conceptual Flow

```
┌─────────────────────┐     ┌─────────────────────┐
│   DIETARY DATA      │     │   BIOMARKER DATA    │
│   (c12diet.csv)     │     │   (biomarker.csv)   │
├─────────────────────┤     ├─────────────────────┤
│ IDind: 12345        │     │ IDind: 12345        │
│ Energy: 2100 kcal   │     │ TC: 185 mg/dl       │
│ Protein: 65g        │     │ HDL-C: 55 mg/dl     │
│ Fat: 70g            │     │ LDL-C: 110 mg/dl    │
│ Carbs: 280g         │     │ TG: 120 mg/dl       │
└─────────────────────┘     └─────────────────────┘
           │                          │
           │    MERGE BY IDind        │
           └──────────┬───────────────┘
                      ▼
         ┌────────────────────────────────┐
         │      MERGED DATASET            │
         ├────────────────────────────────┤
         │ IDind: 12345                   │
         │ Energy: 2100 kcal              │
         │ Protein: 65g                   │
         │ Fat: 70g                       │
         │ Carbs: 280g                    │
         │ TC: 185 mg/dl                  │
         │ HDL-C: 55 mg/dl                │
         │ LDL-C: 110 mg/dl               │
         │ TG: 120 mg/dl                  │
         └────────────────────────────────┘
```

### The Key: Common Identifier (IDind)

- `IDind` = Individual Identifier
- This is the **linking variable** that connects dietary and biomarker records
- Each person has a unique IDind that appears in BOTH files
- Merging matches rows where IDind values are equal

---

## ⚠️ Critical Issues with Your Current Data

### Issue 1: Wave Year Mismatch

| File | Wave Year | Problem |
|------|-----------|---------|
| biomarker.csv | 2009 | ✓ Matches paper |
| c12diet.csv | 2011 | ✗ Does NOT match paper |

**Implications:**
- The paper uses 2009 data for BOTH diet and biomarkers
- If we merge 2009 biomarkers with 2011 dietary data:
  - We're linking a person's 2011 diet to their 2009 blood lipids
  - This is **temporally backwards** (diet should precede or coincide with outcome)
  - Results would not replicate the original study

**Resolution Options:**
1. Obtain 2009 dietary data (preferred)
2. Use 2011 biomarker data if available
3. Proceed with mismatch but document as limitation

### Issue 2: Missing 19 Food Groups

| What Paper Used | What You Have |
|-----------------|---------------|
| 19 individual food groups (g/d) | Only 4 macronutrient totals |
| rice, wheat, pork, vegetables, etc. | d3kcal, d3carbo, d3fat, d3protn |

**Implication:** Cannot perform PCA on food groups without this data

### Issue 3: Unknown ID Overlap

Before merging, we must verify:
- How many IDs exist in dietary data?
- How many IDs exist in biomarker data?
- How many IDs appear in BOTH files?

If overlap is low, sample size after merging will be small.

---

## 📊 Types of Merges Explained

### Inner Join (Recommended for This Study)
- **Keeps:** Only individuals who appear in BOTH files
- **Discards:** Anyone missing from either file
- **Why use it:** Need complete data for analysis

```
Dietary IDs:    [1, 2, 3, 4, 5]
Biomarker IDs:  [3, 4, 5, 6, 7]
                      ↓
Result:         [3, 4, 5]  (only matching IDs)
```

### Left Join
- **Keeps:** All individuals from the "left" (first) file
- **Adds:** Matching data from the "right" file where available
- **Missing:** NA values where no match exists

### Full/Outer Join
- **Keeps:** All individuals from BOTH files
- **Result:** Many NA values where data doesn't overlap

### For This Study: Use Inner Join
- We need BOTH dietary AND biomarker data for each person
- Individuals missing either data type cannot be analyzed
- Inner join ensures complete cases only

---

## 📋 Data Import Checklist

### Before Importing

| Check | Question | Action |
|-------|----------|--------|
| ☐ | File encoding? | Verify UTF-8 or appropriate encoding |
| ☐ | Delimiter type? | CSV uses commas; verify no issues |
| ☐ | Header row present? | First row should be variable names |
| ☐ | Data types expected? | Know which variables are numeric vs. character |

### During Import

| Check | Question | Action |
|-------|----------|--------|
| ☐ | Correct number of rows? | Compare to expected sample size |
| ☐ | Correct number of columns? | Verify all variables present |
| ☐ | ID variable format? | Ensure consistent format across files |
| ☐ | Missing value codes? | Identify how NA/missing is coded |

### After Import

| Check | Question | Action |
|-------|----------|--------|
| ☐ | Data types correct? | Numeric variables read as numeric? |
| ☐ | No parsing errors? | Check for warnings during import |
| ☐ | Variable names clean? | No spaces, special characters |

---

## 🧹 Data Cleaning Tasks

### Task 1: Variable Naming Standardization

**Problem:** Variable names may have inconsistent formats
- Spaces: "HDL C" → "hdl_c"
- Caps: "HDL_C" vs "hdl_c"
- Special characters: "Vitamin A (μg)" → "vitamin_a_ug"

**Standard Convention:**
- All lowercase
- Underscores for spaces
- No special characters
- Descriptive but concise

### Task 2: Data Type Verification

| Variable | Expected Type | Common Issues |
|----------|---------------|---------------|
| IDind | Character or Integer | May be read as numeric with leading zeros lost |
| Wave | Integer | Should be 2009 or 2011 |
| Lipids (TC, HDL, etc.) | Numeric (double) | May have text entries like "NA" or "<5" |
| Energy | Numeric | Extreme values may indicate errors |

### Task 3: Missing Value Handling

**Types of Missing Data:**

| Type | Description | Example |
|------|-------------|---------|
| MCAR | Missing Completely at Random | Lab equipment malfunction |
| MAR | Missing at Random | Older adults less likely to complete recall |
| MNAR | Missing Not at Random | People with poor diets refuse to report |

**Handling Strategies:**

| Strategy | When to Use | Pros | Cons |
|----------|-------------|------|------|
| Complete Case Analysis | Low missingness (<5%) | Simple, unbiased if MCAR | Loses data |
| Mean/Median Imputation | Exploratory analysis | Preserves sample size | Underestimates variance |
| Multiple Imputation | High missingness, MAR | Proper uncertainty | Complex |
| Indicator Method | Categorical missingness | Preserves sample | Creates bias |

**For This Study:**
- Document missing patterns first
- If <5% missing: use complete cases
- If >5% missing: consider imputation or sensitivity analysis

### Task 4: Outlier Detection

**Methods:**

| Method | Definition | Threshold |
|--------|------------|-----------|
| Z-score | Standard deviations from mean | |z| > 3 |
| IQR | Interquartile range | < Q1-1.5×IQR or > Q3+1.5×IQR |
| Clinical | Based on biological plausibility | TC > 400 mg/dl unlikely |

**Handling:**
1. Verify if real (data entry error?) or genuine extreme
2. If error: correct or set to missing
3. If genuine: keep but consider sensitivity analysis

### Task 5: Duplicate Detection

**Check for:**
- Duplicate IDind values within same file
- If duplicates exist: determine which record to keep
  - First occurrence?
  - Most complete record?
  - Average of duplicates?

---

## 🔍 Data Quality Report Template

### Section 1: File Summary

| Attribute | biomarker.csv | c12diet.csv |
|-----------|---------------|-------------|
| Total Rows | ? | ? |
| Total Columns | 48 | 14 |
| Wave | 2009 | 2011 |
| Unique IDs | ? | ? |

### Section 2: Missing Data Summary

| Variable | N Missing | % Missing | Pattern |
|----------|-----------|-----------|---------|
| TC | ? | ? | ? |
| HDL_C | ? | ? | ? |
| LDL_C | ? | ? | ? |
| TG | ? | ? | ? |

### Section 3: Merge Summary

| Metric | Count |
|--------|-------|
| IDs in dietary only | ? |
| IDs in biomarker only | ? |
| IDs in BOTH | ? |
| Final merged sample | ? |

### Section 4: Exclusions

| Exclusion Reason | N Excluded | N Remaining |
|------------------|------------|-------------|
| Missing dietary data | ? | ? |
| Missing biomarker data | ? | ? |
| Age outside 18-80 | ? | ? |
| Male participants | ? | ? |
| **Final Analytic Sample** | — | ? |

---

## 📦 Expected Outputs from Phase 3

### Data Files

| File | Description | Location |
|------|-------------|----------|
| raw_biomarker.csv | Original unmodified | Data/raw/ |
| raw_diet.csv | Original unmodified | Data/raw/ |
| cleaned_biomarker.csv | After cleaning | Data/processed/ |
| cleaned_diet.csv | After cleaning | Data/processed/ |
| merged_analysis.csv | Final merged dataset | Data/processed/ |

### Documentation

| Document | Contents |
|----------|----------|
| Data_Dictionary.md | Variable definitions, units, coding |
| Data_Quality_Report.md | Missing data, outliers, exclusions |
| Merge_Log.md | Merge steps, ID matching results |

### Validation Checks

| Check | Expected | Actual | Status |
|-------|----------|--------|--------|
| Sample size after merge | ~2,468 | ? | ⬜ |
| No duplicate IDs | 0 | ? | ⬜ |
| Lipid values in range | All > 0 | ? | ⬜ |
| No missing key variables | 0 | ? | ⬜ |

---

## 🚦 Go/No-Go Criteria for Phase 4

Before proceeding to Exploratory Data Analysis:

| Criterion | Requirement | Met? |
|-----------|-------------|------|
| Merged dataset created | Yes | ⬜ |
| Sample size adequate | n ≥ 500 | ⬜ |
| Key variables complete | <5% missing | ⬜ |
| Data types correct | All verified | ⬜ |
| Outliers documented | Yes | ⬜ |
| Wave mismatch addressed | Resolved or documented | ⬜ |

---

## 📝 Key Decisions to Document

1. **Which wave to use for dietary data?**
   - Decision: _________________
   - Rationale: _________________

2. **How to handle missing values?**
   - Decision: _________________
   - Rationale: _________________

3. **Which merge type to use?**
   - Decision: Inner join
   - Rationale: Need complete cases for analysis

4. **How to handle outliers?**
   - Decision: _________________
   - Rationale: _________________

5. **Final sample size justification?**
   - Decision: _________________
   - Rationale: _________________

---

## 🔄 Phase 3 Workflow Summary

```
START
  │
  ▼
┌─────────────────────────────────┐
│ 1. IMPORT RAW DATA              │
│    - Load biomarker.csv         │
│    - Load c12diet.csv           │
│    - Verify successful import   │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 2. INITIAL INSPECTION           │
│    - Check dimensions           │
│    - View variable names        │
│    - Examine data types         │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 3. CLEAN EACH DATASET           │
│    - Standardize names          │
│    - Fix data types             │
│    - Handle missing values      │
│    - Detect outliers            │
│    - Remove duplicates          │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 4. CHECK ID OVERLAP             │
│    - Count unique IDs each file │
│    - Identify common IDs        │
│    - Document non-matching IDs  │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 5. MERGE DATASETS               │
│    - Inner join by IDind        │
│    - Verify merge success       │
│    - Check for duplicates       │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 6. APPLY EXCLUSION CRITERIA     │
│    - Filter: Women only         │
│    - Filter: Age 18-80          │
│    - Filter: Complete data      │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 7. FINAL VALIDATION             │
│    - Verify sample size         │
│    - Check variable completeness│
│    - Generate quality report    │
└─────────────────────────────────┘
  │
  ▼
┌─────────────────────────────────┐
│ 8. SAVE & DOCUMENT              │
│    - Export cleaned data        │
│    - Create data dictionary     │
│    - Document all decisions     │
└─────────────────────────────────┘
  │
  ▼
PROCEED TO PHASE 4 (EDA)
```

---

*Document: Phase 3 - Data Import & Cleaning*  
*Status: DETAILED SPECIFICATION (No Code)*  
*Next Step: Resolve data gaps, then implement*

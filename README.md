# Adult Census Income: Preprocessing & Exploratory Data Analysis

## 📖 Project Overview
This repository contains a complete data preprocessing and exploratory data analysis (EDA) pipeline for the **Adult (Census Income)** dataset. The project was completed as part of an Introduction to Data Science mid-term project.

The dataset consists of **32,561 records** and **15 columns** extracted from the 1994 U.S. Census. The target variable is `income`, a binary classification indicating whether an individual earns `>50K` or `<=50K` annually.

**Dataset Source:** 
Becker, B. & Kohavi, R. (1996). *Adult* [Dataset]. UCI Machine Learning Repository. [https://doi.org/10.24432/C5XW20](https://doi.org/10.24432/C5XW20)

## 📂 Repository Structure
*   `adult_income.csv` - The original raw dataset (download from the UCI link above).
*   `Preprocessing Pipeline - Adult Census Income.R` - The complete R script covering data cleaning, transformation, EDA, and splitting.
*   `Project Report - Adult Census Income.pdf` - The detailed report with interpretations and outputs.
*   `README.md` - Project documentation.
*   `images/` - Folder containing the exported plots and figures.

## 🛠️ Methodology & Workflow
To demonstrate robust data cleaning techniques, artificial data quality issues were intentionally injected into a clean copy of the dataset before being resolved.

### 1. Data Quality Injection & Cleaning
*   **Missing Values:** Introduced `NA` values into `age` and `hours_per_week`, and converted the dataset's native `"?"` strings into proper `NA` values for `workclass`, `occupation`, and `native_country`.
*   **Invalid Data:** Injected impossible values (e.g., negative age, 150 years old, negative working hours) and an invalid category (`"Unknown"` sex). These were quarantined and replaced with `NA`.
*   **Inconsistent Text:** Injected lowercase (`"private"`) and whitespace-padded (`" PRIVATE "`) strings. Resolved using targeted `trimws()` and case-mapping.
*   **Duplicates:** Added 5 duplicate rows. Deduplication was performed *after* text normalization.

### 2. Missing Value Imputation
*   **Numeric Data:** `age` and `hours_per_week` were right-skewed, so gaps were filled using the **median**.
*   **Categorical Data:** A custom `Mode` function was written in base R to impute missing `workclass`, `occupation`, `native_country`, and `sex`.

### 3. Outlier Handling
*   **Age:** Left unchanged, as the flagged outliers were realistic ages for older workers.
*   **Capital Gain:** Highly right-skewed (91.7% zeros). Capped at the 99th percentile (**$15,024**) to handle extreme values and census top-codes (99,999).

### 4. Feature Engineering & Transformation
*   **Type Conversion:** Text columns converted to factors. 
*   **Binning:** Continuous `age` binned into `Age_Group` (Young, Adult, Middle-aged, Senior).
*   **Label Encoding:** Binary `sex` converted to `Sex_Code` (1 for Male, 0 for Female).
*   **Normalization:** `hours_per_week` min-max scaled to `Hours_Normalized` [0, 1].

### 5. Class Imbalance
The dataset exhibited a **76/24 split** in the target variable. The majority class (`<=50K`) was undersampled to match the minority class (`>50K`), creating a perfectly balanced dataset (7,839 vs 7,839) for modeling.

### 6. Data Splitting
A **stratified 80/20 train-test split** was created using `caret::createDataPartition` to ensure both sets maintain the exact same income class balance as the full dataset.

---

## 📊 Key Visualizations & Findings

> **Note:** Make sure to export your R plots as PNGs, place them in an `images` folder, and match the filenames below.

### Missing Values Analysis
Missingness in `workclass` was not random. **51%** of individuals with missing employment data were either under 25 or over 65, indicating they were mostly students or retirees. 

![Missing Values by Column](images/fig1.png)

### Outlier Detection
`capital_gain` required capping due to extreme values and census top-coding. Age contained a few outliers but they were valid, real-world ages.

![Age Distribution](images/fig2.png)
![Capital Gain Distribution](images/fig3.png)

### Class Imbalance
The original dataset was heavily skewed toward the `<=50K` income bracket.

![Income Distribution](images/fig4.png)

### Statistical Comparisons
*   **Working Hours:** A Welch Two Sample t-test revealed a statistically significant difference in working hours (p < 2.2e-16). High earners work on average **45.5 hours/week**, while lower earners work **38.8 hours/week**.
*   **Age & Education:** High earners are older (mean 44.2 vs 36.8) and have more years of education (11.6 vs 9.6).

![Working Hours by Income](images/fig5.png)

### Employment Categories
Age spread varies significantly by work class. Self-employed individuals are the oldest (mean ~45-46), while private sector workers are the youngest of the large categories (mean ~37.1).

![Age Spread Across Work Classes](images/fig6.png)

---

## 🚀 How to Run
1.  Clone this repository:
    ```bash
    git clone https://github.com/your-username/adult-census-preprocessing.git

# Introduction to Data Science - Mid-Term Project
# Adult / Census Income dataset, 32,561 records, 15 columns
# Source: UCI Machine Learning Repository
# https://archive.ics.uci.edu/dataset/2/adult
# Becker, B. & Kohavi, R. (1996). Adult [Dataset]. https://doi.org/10.24432/C5XW20
#
# Section numbers match the report. Run top to bottom, order matters.


# install.packages(c("readr", "dplyr", "ggplot2", "caret"))   # first time only

library(readr)
library(dplyr)
library(ggplot2)
library(caret)

# setwd("C:/Users/YourName/Desktop/IDS_Project")   # change to your folder


# ---- 2. Load the data ----

adult_income <- read_csv("adult_income.csv")

dim(adult_income)
str(adult_income)
summary(adult_income)


# ---- 3. Add some data quality problems ----
# The brief wants us to introduce issues and then fix them.
# Work on a copy so the original stays clean.

adult <- adult_income

# this file already uses "?" for missing values
sum(adult$workclass == "?")
sum(adult$occupation == "?")
sum(adult$native_country == "?")

# missing values
adult$age[c(5, 20, 100)] <- NA
adult$hours_per_week[c(50, 120)] <- NA

# values that can't exist
adult$age[10] <- -8
adult$age[30] <- 150
adult$hours_per_week[60] <- -5

# invalid category
adult$sex[15] <- "Unknown"

# messy text
adult$workclass[25] <- "private"
adult$workclass[40] <- " PRIVATE "

# duplicate rows
adult <- rbind(adult, adult[1:5, ])

# turn the "?" into real NA, otherwise R counts them as a normal category
adult$workclass[adult$workclass == "?"] <- NA
adult$occupation[adult$occupation == "?"] <- NA
adult$native_country[adult$native_country == "?"] <- NA

dim(adult)
sum(duplicated(adult))
colSums(is.na(adult))


# ---- 4. Look at the missing values ----

missing_values <- colSums(is.na(adult))
print(missing_values)

barplot(missing_values,
        las  = 2,
        col  = "steelblue",
        main = "Missing Values by Column",
        ylab = "Count")

# check if the missingness is random
sum(is.na(adult$workclass) & is.na(adult$occupation))   # they go missing together

# how many of those people are very young or very old
mean(adult$age[is.na(adult$workclass)] < 25 |
     adult$age[is.na(adult$workclass)] > 65, na.rm = TRUE) * 100

# compared to everyone else
mean(adult$age[!is.na(adult$workclass)] < 25 |
     adult$age[!is.na(adult$workclass)] > 65, na.rm = TRUE) * 100

# about 51% vs 19%, so mostly students and retirees


# ---- 5. Fix the messy text ----
# only the two cells we broke need fixing, the rest of the labels are fine,
# so don't run a blanket toupper/title-case over the whole column

adult$workclass <- trimws(adult$workclass)
adult$workclass[tolower(adult$workclass) == "private"] <- "Private"

adult$sex <- trimws(adult$sex)

table(adult$workclass)
table(adult$sex)


# ---- 6. Invalid data ----
# right type, impossible value. Set to NA instead of dropping the row,
# the other 14 fields in that row are still fine.

adult[adult$age < 0, ]
adult[adult$age > 100, ]
adult[adult$hours_per_week < 0, ]

summary(adult$age)          # min -8, max 150

adult$age[adult$age < 0]   <- NA
adult$age[adult$age > 100] <- NA
adult$hours_per_week[adult$hours_per_week < 0] <- NA
adult$sex[adult$sex == "Unknown"] <- NA

sum(is.na(adult$age))              # 4 -> 6
sum(is.na(adult$hours_per_week))   # 2 -> 3


# ---- 7. Fill in the missing values ----
# numeric: median, both columns are skewed so the mean would get dragged up
# categorical: mode, since mean/median make no sense for text

adult$age[is.na(adult$age)] <- median(adult$age, na.rm = TRUE)

adult$hours_per_week[is.na(adult$hours_per_week)] <-
  median(adult$hours_per_week, na.rm = TRUE)

# base R has no mode function so write one
Mode <- function(x) {
  ux <- na.omit(unique(x))
  ux[which.max(tabulate(match(x, ux)))]
}

adult$workclass[is.na(adult$workclass)]           <- Mode(adult$workclass)
adult$occupation[is.na(adult$occupation)]         <- Mode(adult$occupation)
adult$native_country[is.na(adult$native_country)] <- Mode(adult$native_country)
adult$sex[is.na(adult$sex)]                       <- Mode(adult$sex)

sum(is.na(adult))   # should be 0


# ---- 8. Remove duplicates ----
# do this after the text is cleaned, "Male" and "MALE" rows
# don't count as duplicates until then

before <- nrow(adult)
adult  <- adult[!duplicated(adult), ]
after  <- nrow(adult)

cat("Rows before:", before, "\n")
cat("Rows after:",  after,  "\n")


# ---- 9. Outliers ----

boxplot(adult$age,          main = "Age Outliers",          col = "lightgreen")
boxplot(adult$capital_gain, main = "Capital Gain Outliers", col = "orange")

# capital_gain is mostly zeros with a long tail, cap it at the 99th percentile
cap <- quantile(adult$capital_gain, 0.99)
cap
sum(adult$capital_gain > cap)
sum(adult$capital_gain == 99999)                    # census top-code, not a real amount
round(mean(adult$capital_gain == 0) * 100, 1)       # % zeros

adult$capital_gain[adult$capital_gain > cap] <- cap

# age outliers are just older workers, leave them alone


# ---- 10. Convert types + normalise ----

# text to factor
adult$income    <- as.factor(adult$income)
adult$sex       <- as.factor(adult$sex)
adult$workclass <- as.factor(adult$workclass)

# numeric to categorical (binning)
adult$Age_Group <- cut(adult$age,
                       breaks = c(0, 25, 45, 65, 100),
                       labels = c("Young", "Adult", "Middle-aged", "Senior"),
                       include.lowest = TRUE)

# categorical to numeric. Fine here because sex only has 2 levels,
# would be wrong for something like race
adult$Sex_Code <- ifelse(adult$sex == "Male", 1, 0)

# min-max normalisation, puts hours_per_week on a 0 to 1 scale
adult$Hours_Normalized <-
  (adult$hours_per_week - min(adult$hours_per_week)) /
  (max(adult$hours_per_week) - min(adult$hours_per_week))

table(adult$Age_Group)
summary(adult$Hours_Normalized)


# ---- 11. Class imbalance ----
# roughly 76/24 split. Undersample the majority class to even it out.
# keep this separate from `adult`, the EDA below should use the real proportions

table(adult$income)

barplot(table(adult$income),
        col  = c("skyblue", "tomato"),
        main = "Income Distribution")

set.seed(123)
low  <- adult[adult$income == "<=50K", ]
high <- adult[adult$income == ">50K",  ]
n    <- min(nrow(low), nrow(high))

balanced <- rbind(low[sample(nrow(low), n), ], high)
table(balanced$income)


# ---- 12. Stats across the two income classes ----

adult %>%
  group_by(income) %>%
  summarise(
    Average_Age   = mean(age),
    Median_Age    = median(age),
    SD_Age        = sd(age),
    Average_Hours = mean(hours_per_week),
    Education     = mean(education_num)
  )


# ---- 13. Compare average hours between the two groups ----

t.test(hours_per_week ~ income, data = adult)

boxplot(hours_per_week ~ income,
        data = adult,
        col  = c("lightblue", "pink"),
        main = "Working Hours by Income")


# ---- 14. Compare age spread across work classes ----

adult %>%
  group_by(workclass) %>%
  summarise(
    Mean_Age = mean(age),
    SD       = sd(age)
  )

boxplot(age ~ workclass,
        data = adult,
        las  = 2,
        col  = "lightgreen")


# ---- 15. Filtering ----

high_earners <- adult %>% filter(income == ">50K", age > 40)
nrow(high_earners)

overworked <- adult %>% filter(hours_per_week > 60, workclass == "Private")
nrow(overworked)

# filter then count
adult %>% filter(Age_Group == "Senior") %>% count(income)

# filter, sort, pick columns
adult %>%
  filter(income == ">50K") %>%
  arrange(desc(hours_per_week)) %>%
  select(age, workclass, education_num, hours_per_week, income) %>%
  head(5)


# ---- 16. Train / test split ----
# createDataPartition splits within each class, so both sets keep the
# same income balance as the full data

set.seed(123)
index <- createDataPartition(adult$income, p = 0.80, list = FALSE)
train <- adult[index, ]
test  <- adult[-index, ]

dim(train)
dim(test)


# ---- 17. Final dataset ----

summary(adult)
head(adult)
tail(adult)

# write.csv(adult, "adult_cleaned.csv", row.names = FALSE)

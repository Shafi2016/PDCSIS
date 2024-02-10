### Installation


```
devtools::install_github("https://github.com/Shafi2016/PDCSIS.git")
```

### Usage Examples



```r
library(PDCSIS)
library(energy)
library(dplyr)
library(gtools) # For mixedorder
set.seed(23)

url <- "https://raw.githubusercontent.com/Shafi2016/PDCSIS/main/data/google_trends.csv"
df <- read.csv(url)

# Extracting the GDP column as the target variable 'Y'
gdp <- df[,"gdpm"]

# Extracting the predictors
data <- df[,3:83] # Adjust column indices as per your dataset

# Creating lagged variables up to Lag 3
PredictLag3 <- data %>%
  mutate_all(list(lag1 = ~lag(.), lag2 = ~lag(., 2), lag3 = ~lag(., 3))) %>%
  select(gtools::mixedorder(names(.)))

# Adjusting 'Xwl' to exclude rows with NAs introduced by lagging, ensuring alignment with 'Y'
Xwl <- as.matrix(PredictLag3[-c(1:3),]) # Excluding the first 3 rows due to NA from lagging

# Adjust 'gdp' to match the reduced dataset size
Y <- gdp[-c(1:3)] # Excluding the first 3 rows to match 'Xwl'

n2 <- nrow(Xwl) # Update 'n2' to reflect the number of rows in 'Xwl' after exclusion

# Apply the function
results <- PDC_SIS(Xwl, Y, lags = 1, top_n = 10)

print(results$indices)

# Output the data frame of lagged versions of Y
print(head(results$Y_conditioning_df))


# Assuming results$indices contains the indices of selected columns
selected_indices <- results$indices

# Initialize an empty list to store the selected data frames
selected_columns_list <- list()

# Loop over each index in selected_indices
for (idx in selected_indices) {
  # Select the column from Xwl
  selected_column <- as.data.frame(Xwl[, idx, drop = FALSE])
  
  # Retrieve the original name for the column from PredictLag3
  original_column_name <- names(PredictLag3)[idx]  # Ensure this aligns with how Xwl was constructed
  
  # Rename the column in the selected data frame
  names(selected_column) <- original_column_name
  
  # Add the selected column data frame to the list
  selected_columns_list[[original_column_name]] <- selected_column
}

# Combine all selected columns into one data frame
selected_columns_df <- do.call(cbind, selected_columns_list)

# View the first few rows of the combined data frame
head(selected_columns_df)

```
### Reference

**Title:** Targeting Predictors Via Partial Distance Correlation With Applications to Financial Forecasting

**Authors:** Kashif Yousufa and Yang Feng

[Read the paper here](https://yangfeng.hosting.nyu.edu/publication/yousuf-2018-partial/yousuf-2018-partial.pdf)

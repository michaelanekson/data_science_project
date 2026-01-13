#Load libraries
library(tidyverse)
library(stringr)

#1. Load the data
rec_features <- read.csv("D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/laptops_recommender_features.csv")
glimpse(rec_features)
rec_efatures <- rec_features %>% rename(`Actual Price` = Actual.Price)

#2. Define the recommendation function
recommend_laptops <- function(
    data,
    budget,
    w_price = 0.30,
    w_cpu = 0.25,
    w_ram = 0.20,
    w_storage = 0.15,
    w_gpu = 0.10,
    top_n = 5
) {
  
  # --- sanity check ---
  total_weight <- w_price + w_cpu + w_ram + w_storage + w_gpu
  if (abs(total_weight - 1) > 0.001) {
    stop("Weights must sum to 1")
  }
  
  # --- hard constraint: budget ---
  candidates <- data %>%
    filter(`Actual Price` <= budget)
  
  if (nrow(candidates) == 0) {
    return(tibble(
      message = "No laptops found within the given budget."
    ))
  }
  
  # --- final weighted score ---
  candidates <- candidates %>%
    mutate(
      Final_Score =
        w_price   * Price_Score +
        w_cpu     * CPU_Score +
        w_ram     * RAM_Score +
        w_storage * Storage_Score +
        w_gpu     * GPU_Score
    )
  
  # --- top N recommendations ---
  candidates %>%
    arrange(desc(Final_Score)) %>%
    slice_head(n = top_n) %>%
    select(
      Name, Brand,
      `Actual Price`,
      RAM_GB, Storage_GB,
      CPU_Tier, GPU_Tier,
      Final_Score
    )
}

#3. Test the recommender
recommend_laptops(
  data = rec_features,
  budget = 300000,
  w_price = 0.35,
  w_cpu = 0.25,
  w_ram = 0.20,
  w_storage = 0.10,
  w_gpu = 0.10,
  top_n = 5
)


#4. Example user profiles
# Student / Office
recommend_laptops(
  rec_features,
  budget = 250000,
  w_price = 0.45,
  w_cpu = 0.20,
  w_ram = 0.20,
  w_storage = 0.10,
  w_gpu = 0.05
)

# Gamer
recommend_laptops(
  rec_features,
  budget = 400000,
  w_price = 0.20,
  w_cpu = 0.25,
  w_ram = 0.20,
  w_storage = 0.15,
  w_gpu = 0.20
)

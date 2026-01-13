#Load libraries
library(tidyverse)
library(stringr)

#1. Load the data
data_clean <- read.csv("D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/laptops_clean.csv")
glimpse(laptops_clean)

#2. Decide eligibility rules (very important)
laptops_rec <- laptops_clean %>%
  filter(
    !is.na(`Actual Price`),
    !is.na(RAM_GB),
    !is.na(Storage_GB),
    !is.na(CPU_Tier)
  )

#3. Convert categorical tiers → numeric scores
laptops_rec <- laptops_rec %>%
  mutate(
    CPU_Score = case_when(
      CPU_Tier == "High" ~ 4,
      CPU_Tier == "Upper-Mid" ~ 3,
      CPU_Tier == "Mid" ~ 2,
      CPU_Tier == "Entry" ~ 1
    )
  )

laptops_rec <- laptops_rec %>%
  mutate(
    GPU_Score = case_when(
      GPU_Tier == "High" ~ 3,
      GPU_Tier == "Upper-Mid" ~ 2,
      GPU_Tier == "Mid" ~ 1,
      TRUE ~ 0
    )
  )

#4. Normalize numeric features
laptops_rec <- laptops_rec %>%
  mutate(
    RAM_Score = scale(RAM_GB)[,1],
    Storage_Score = scale(Storage_GB)[,1],
    Price_Score = scale(-`Actual Price`)[,1]  # lower price = higher score
  )

#5. Create a recommender-ready feature table
rec_features <- laptops_rec %>%
  select(
    ID, Name, Brand,
    `Actual Price`,
    RAM_GB, Storage_GB,
    CPU_Tier, GPU_Tier,
    RAM_Score, Storage_Score,
    CPU_Score, GPU_Score,
    Price_Score
  )


write_csv(
  rec_features,
  "D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset//laptops_recommender_features.csv"
)

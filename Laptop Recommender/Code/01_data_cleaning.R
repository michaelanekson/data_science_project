#Load libraries
library(tidyverse)
library(stringr)

#1. Load the dataset
laptops <- read_csv("D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/priceoye_laptops_version_2.csv")
colnames(laptops) #check column names

laptops_f <- laptops %>% rename(ID = "...1")

#2. Check dataset properties
#Check the dataset dimension
dim(laptops)

#Check the dataset
glimpse(laptops_f)
str(laptops_f)

#Check missing values
colSums(is.na(laptops_f))

#Check price
summary(laptops_f$`Actual Price`)

#Check laptop brand
laptops_f %>%
  count(Brand, sort = TRUE)
laptops_f <- laptops_f %>%
  mutate(
    Brand = str_to_title(Brand)
  )

#3. Extract RAM and storage information
unique(laptops_f$SSD)
#Extract RAM
laptops_f <- laptops_f %>%
  mutate(
    RAM_GB = str_extract(SSD, "^\\d+GB") %>%
      str_remove("GB") %>%
      as.numeric()
  )
#Extract Storage
laptops_f <- laptops_f %>%
  mutate(
    Storage_GB = str_extract(SSD, "(?<=-)\\d+GB") %>%
      str_remove("GB") %>%
      as.numeric()
  )
#Extract GPU
laptops_f <- laptops_f %>%
  mutate(
    Has_GPU = str_detect(Model, "RTX|GTX|Graphics")
  )
laptops_f <- laptops_f %>%
  mutate(
    GPU_Family = case_when(
      str_detect(Name, "RTX") ~ "RTX",
      str_detect(Name, "GTX") ~ "GTX",
      str_detect(Name, "Radeon") ~ "Radeon",
      TRUE ~ NA_character_
    )
  )
laptops_f <- laptops_f %>%
  mutate(
    GPU_Model = str_extract(Name, "(RTX|GTX|Radeon)\\s*\\d{3,4}") %>%
      str_extract("\\d{3,4}") %>%
      as.numeric()
  )
laptops_f <- laptops_f %>%
  mutate(
    GPU_Model = str_extract(
      Name,
      "(RTX|GTX|Radeon)[-\\s]?\\d{3,4}"
    ) %>%
      str_extract("\\d{3,4}") %>%
      as.numeric()
  )
laptops_f <- laptops_f %>%
  mutate(
    GPU_Tier = case_when(
      GPU_Model >= 4070 ~ "High",
      GPU_Model >= 4060 ~ "Upper-Mid",
      GPU_Model >= 3050 ~ "Mid",
      TRUE ~ NA_character_
    )
  )

#4. Finalize the core model
laptops_f <- laptops_f %>%
  mutate(
    CPU_Text = coalesce(Core, Name)
  )
laptops_f <- laptops_f %>%
  mutate(
    CPU_Brand = case_when(
      str_detect(CPU_Text, "Intel|Core|Ultra|Ci") ~ "Intel",
      str_detect(CPU_Text, "Ryzen|AMD") ~ "AMD",
      str_detect(CPU_Text, "M1|M2|M3|M4") ~ "Apple",
      TRUE ~ NA_character_
    )
  )
laptops_f <- laptops_f %>%
  mutate(
    CPU_Tier = case_when(
      str_detect(CPU_Text, "Ultra\\s*9|i9|Ci9") ~ "High",
      str_detect(CPU_Text, "Ultra\\s*7|i7|Ci7") ~ "Upper-Mid",
      str_detect(CPU_Text, "Ultra\\s*5|i5|Ci5") ~ "Mid",
      str_detect(CPU_Text, "i3|Ci3") ~ "Entry",
      TRUE ~ NA_character_
    )
  )

#5. Extract SSD from Name column
laptops_f <- laptops_f %>%
  mutate(
    RAM_from_Name = str_extract(Name, "\\d+GB(?=-)") %>%
      str_remove("GB") %>%
      as.numeric(),
    
    Storage_from_Name = str_extract(Name, "\\(\\d+GB-\\d+GB\\)") %>%
      str_extract("\\d+GB\\)") %>%
      str_remove("GB\\)") %>%
      as.numeric()
  )

laptops_f <- laptops_f %>%
  mutate(
    RAM_GB = coalesce(RAM_from_SSD, RAM_from_Name),
    Storage_GB = coalesce(Storage_from_SSD, Storage_from_Name)
  )

laptops_f %>%
  filter(is.na(SSD) & !is.na(RAM_GB)) %>%
  select(Name, SSD, RAM_GB, Storage_GB) %>%
  head(10)

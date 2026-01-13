#Load libraries
library(tidyverse)
library(stringr)

#1. Load the dataset
laptops <- read_csv("D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/priceoye_laptops_version_2.csv")
colnames(laptops) #check column names

laptops_f <- laptops %>% rename(ID = "...1")

glimpse(laptops_f)
colSums(is.na(laptops_f))

#2. Normalize brand names
laptops_f <- laptops_f %>%
  mutate(
    Brand = str_to_title(Brand)
  )

#3. GPU extraction (clean, single pass)
laptops_f <- laptops_f %>%
  mutate(
    Has_GPU = str_detect(Name, "RTX|GTX|Radeon"),
    
    GPU_Family = case_when(
      str_detect(Name, "RTX") ~ "RTX",
      str_detect(Name, "GTX") ~ "GTX",
      str_detect(Name, "Radeon") ~ "Radeon",
      TRUE ~ NA_character_
    ),
    
    GPU_Model = str_extract(
      Name,
      "(RTX|GTX|Radeon)[-\\s]?\\d{3,4}"
    ) %>%
      str_extract("\\d{3,4}") %>%
      as.numeric(),
    
    GPU_Tier = case_when(
      GPU_Model >= 4070 ~ "High",
      GPU_Model >= 4060 ~ "Upper-Mid",
      GPU_Model >= 3050 ~ "Mid",
      TRUE ~ NA_character_
    )
  )


#4. CPU extraction & tiering
laptops_f <- laptops_f %>%
  mutate(
    CPU_Text = coalesce(Core, Name),
    
    CPU_Brand = case_when(
      str_detect(CPU_Text, "Intel|Core|Ultra|Ci") ~ "Intel",
      str_detect(CPU_Text, "Ryzen|AMD") ~ "AMD",
      str_detect(CPU_Text, "M1|M2|M3|M4") ~ "Apple",
      TRUE ~ NA_character_
    ),
    
    CPU_Tier = case_when(
      CPU_Brand == "Apple" & str_detect(CPU_Text, "M4|M3") ~ "High",
      CPU_Brand == "Apple" & str_detect(CPU_Text, "M2") ~ "Upper-Mid",
      CPU_Brand == "Apple" & str_detect(CPU_Text, "M1") ~ "Mid",
      
      str_detect(CPU_Text, "Ultra\\s*9|i9|Ci9") ~ "High",
      str_detect(CPU_Text, "Ultra\\s*7|i7|Ci7") ~ "Upper-Mid",
      str_detect(CPU_Text, "Ultra\\s*5|i5|Ci5") ~ "Mid",
      str_detect(CPU_Text, "i3|Ci3") ~ "Entry",
      
      TRUE ~ NA_character_
    )
  )

#5. RAM & Storage extraction (??? GB + ??? TB, ??? SSD + ??? Name)
laptops_f <- laptops_f %>%
  mutate(
    # ---- RAM from SSD (primary source) ----
    RAM_from_SSD = str_extract(SSD, "^\\d+GB") %>%
      str_remove("GB") %>%
      as.numeric(),
    
    # ---- Storage from SSD (GB / TB) ----
    Storage_raw_SSD = str_extract(SSD, "\\d+(GB|TB)"),
    
    Storage_from_SSD = case_when(
      str_detect(Storage_raw_SSD, "TB") ~
        as.numeric(str_remove(Storage_raw_SSD, "TB")) * 1024,
      str_detect(Storage_raw_SSD, "GB") ~
        as.numeric(str_remove(Storage_raw_SSD, "GB")),
      TRUE ~ NA_real_
    ),
    
    # ---- Extract everything inside parentheses ----
    Memory_Block = str_extract(Name, "\\([^)]*\\)"),
    
    # ---- Extract ALL memory units inside parentheses ----
    Memory_Units = str_extract_all(Memory_Block, "\\d+(GB|TB)"),
    
    # ---- RAM = first memory unit ----
    RAM_from_Name = map_dbl(Memory_Units, ~ {
      if (length(.x) >= 1) {
        as.numeric(str_remove(.x[1], "GB|TB"))
      } else {
        NA_real_
      }
    }),
    
    # ---- Storage = last memory unit ----
    Storage_from_Name = map_dbl(Memory_Units, ~ {
      if (length(.x) >= 2) {
        if (str_detect(.x[length(.x)], "TB")) {
          as.numeric(str_remove(.x[length(.x)], "TB")) * 1024
        } else {
          as.numeric(str_remove(.x[length(.x)], "GB"))
        }
      } else {
        NA_real_
      }
    }),
    
    # ---- Final merged values ----
    RAM_GB = coalesce(RAM_from_SSD, RAM_from_Name),
    Storage_GB = coalesce(Storage_from_SSD, Storage_from_Name)
  )


#6. Validation (must always exist in data_cleaning.R)
laptops_f %>%
  filter(is.na(SSD) & !is.na(RAM_GB)) %>%
  select(Name, SSD, RAM_GB, Storage_GB) %>%
  head(10)

laptops_f %>%
  filter(str_detect(Name, "1TB")) %>%
  select(Name, Storage_GB)

laptops_clean <- laptops_f %>%
  select(
    -Memory_Block,
    -Memory_Units,
    -RAM_from_SSD,
    -RAM_from_Name,
    -Storage_raw_SSD,
    -Storage_raw_Name,
    -Storage_from_SSD,
    -Storage_from_Name
  )

write.csv(laptops_clean, "D:/FOX/China Medical University/Proyek penelitian/Bioinformatics CMU/Report/Personal project/Data Science/Laptop Recommender/Dataset/laptops_clean.csv", row.names = F)

# 🧠 Laptop Recommendation System (End-to-End Data Science Project)

An **end-to-end laptop recommendation system** that transforms raw, messy e-commerce product data into **personalized, budget-constrained laptop recommendations** through an interactive **R Shiny web application**.

This project demonstrates the **complete data science lifecycle**, from data ingestion and cleaning to feature engineering, recommendation logic, and deployment.

---

## 📌 Project Motivation

Choosing a laptop is a **multi-criteria decision problem** involving trade-offs between:

- Budget
- Performance (CPU, RAM, GPU)
- Storage capacity
- User preferences (e.g. gaming vs office use)

The goal of this project is to:

> **Help users find the best laptop given their budget and preferences in a transparent and interpretable way.**

Instead of using a black-box model, this project focuses on **explainable, rule-based recommendation logic**, which closely mirrors how many real-world e-commerce systems are initially built.

---


Each script has a **single responsibility**, following good data engineering and software design practice.

---

## 🔄 End-to-End Workflow

### 1️⃣ Data Ingestion & Cleaning (`01_data_cleaning.R`)

- Load raw e-commerce laptop data
- Normalize brand names
- Handle missing values
- Extract hardware specifications embedded in free-text fields:
  - RAM (GB)
  - Storage (GB / TB, standardized to GB)
  - CPU family and tier
  - GPU presence and tier
- Resolve real-world data issues:
  - Inconsistent formatting (e.g. `16GB-1TB`, `16GB 1TB`)
  - Mixed units (GB vs TB)
  - GPU VRAM vs system RAM ambiguity
- Output a **clean, analysis-ready dataset**

**Output:** `laptops_clean.csv`

---

### 2️⃣ Feature Engineering (`02_feature_engineering.R`)

- Filter laptops eligible for recommendation
- Convert categorical tiers into **numeric utility scores**
  - `CPU_Score`
  - `GPU_Score`
- Normalize continuous features:
  - RAM
  - Storage
  - Price (inverted so lower price = higher score)
- Prepare a **recommender-ready feature table**

**Output:** `laptops_recommender_features.csv`

---

### 3️⃣ Recommendation Logic (`03_recommender_logic.R`)

A **rule-based, preference-weighted recommender system** with:

- **Hard constraint:** user-defined budget
- **Soft constraints:** user preference weights
- Transparent scoring formula:
Final Score =
w_price × Price_Score +
w_cpu × CPU_Score +
w_ram × RAM_Score +
w_storage × Storage_Score +
w_gpu × GPU_Score


This approach prioritizes **interpretability, flexibility, and explainability**.

---

### 4️⃣ Interactive Deployment (`04_shiny_app.R`)

A fully functional **R Shiny web application** that allows users to:

- Set a budget (in PKR – Pakistani Rupees)
- Adjust preference weights via sliders
- Receive ranked laptop recommendations in real time

Key features:
- Budget-constrained filtering
- Live preference tuning
- Clean and intuitive UI
- Clear separation of UI and backend logic

---

## 🌍 Localization

- Dataset and interface are localized for the **Pakistan market**
- Prices displayed in **PKR**
- Recommendation logic remains currency-agnostic and reusable

---

## 🛠️ Technologies Used

- R
- tidyverse
- stringr
- purrr
- Shiny

---

## 🧠 Key Design Decisions

- **Rule-based recommender instead of black-box ML**
  - Easier to explain and debug
  - Common starting point in production systems
- **Separation of concerns**
  - Data cleaning ≠ Feature engineering ≠ Recommendation ≠ Deployment
- **Robust text parsing**
  - Explicit handling of messy real-world product descriptions
- **Reproducible pipeline**
  - Clean data saved and reused downstream

---

## 📈 Possible Extensions

- Similarity-based recommender (cosine similarity)
- Preset user profiles (Student / Office / Gamer)
- Visual explanation of score components
- Deployment to `shinyapps.io`
- Model-based recommender for comparison

---

## 🧪 How to Run the Project

1. Clone the repository
2. Open RStudio
3. Run scripts in order:
   ```r
   01_data_cleaning.R
   02_feature_engineering.R
   03_recommender_logic.R
   04_shiny_app.R



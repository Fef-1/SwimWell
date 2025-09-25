# 🏊 SwimWell — SQL Analysis of Sports Impact on Health & Wellbeing  

![BigQuery](https://img.shields.io/badge/BigQuery-SQL-blue?logo=googlecloud) 
![Looker](https://img.shields.io/badge/Looker-Dashboards-orange?logo=looker) 
![Status](https://img.shields.io/badge/Project-Completed-success)

---

## 🎯 Objective  
This project explores how different sports (Swimming, Running, Yoga, etc.) affect **sleep quality**, **stress levels**, and overall **wellbeing**.  

We analyzed data from **3,000 participants** who practiced 10 sports throughout 2024, with each row representing a **daily activity session**.  
The goal: detect how health metrics evolve depending on sports practice and combinations of activities.  

---

## 📊 Tools & Stack  
- **Google BigQuery (SQL)** — data transformation & metrics calculation  
- **Looker (Google Data Studio)** — interactive dashboards for exploration  

---

## 🔑 Methodology  
1. **Filter & validation of participants**  
   - Only participants with ≥ **15% of time** in a given sport.  
   - At least **30 days** between first and last session to ensure meaningful evolution.  

2. **Build evolution metrics**  
   - **Sleep evolution** = difference in average sleep hours (first 7 vs last 7 sessions).  
   - **Stress evolution** = difference in average stress level (first 7 vs last 7 sessions).  
   - **Categorization** of sleepers & stress profiles (e.g. *"Good sleeper"* → *"Average sleeper"*).  

3. **Integration back into main dataset**  
   - Join evolution metrics with the daily activity dataset to enable combined analysis in Looker.  

---

## 📂 Repository Structure  
sql/

├── 01_main_dataset_transformed.sql         – Original dataset transformed with to compute evolution metrics

looker/

├── dashboard_screenshots/        – Key dashboard views

└── README.md                     – How to access Looker (view-only link)

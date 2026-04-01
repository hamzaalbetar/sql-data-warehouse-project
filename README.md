#  sql-data-warehouse-project
## Designed & Implemented by Hamza Albetar

## 🧱 Architecture Overview

### 🥉 Bronze Layer – Raw Ingestion

Read original CSV files

No transformations

Preserve source data as single source of truth

### 🥈 Silver Layer – Cleansed & Integrated

Data cleaning & normalization

Schema standardization

Integration between CRM and ERP domains

#### 📌 Silver Tables

Silver_crm_cust_info

Silver_crm_prd_info

Silver_crm_sales_details

Silver_erp_cust_az12

Silver_erp_loc_a101

Silver_erp_px_cat_g1v2

### 🥇 Gold Layer – Dimensional Model

Gold.dim_customers

Gold.dim_products

Gold.fact_sales

Built using Star Schema to support analytics and BI workloads.

### ✅ Data Quality Rules

No null values in business keys

Unique customer & product IDs

Positive sales amounts

Referential integrity between fact and dimensions

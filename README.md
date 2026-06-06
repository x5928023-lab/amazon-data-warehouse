# Amazon Order & Revenue Data Warehouse

## Overview
This project builds a production-style data warehouse for analyzing Amazon order and delivery performance.

It transforms raw transactional data into a structured analytics system that enables revenue tracking, customer insights, and operational decision-making.

The project simulates a real-world data engineering and analytics workflow, covering ETL pipelines, dimensional modeling, and business intelligence.

---

## Architecture

Data pipeline:

Raw Data (Orders & Delivery)  
→ Staging Layer  
→ Cleaned Tables  
→ Dimension Tables  
→ Fact Tables  
→ Business Analytics & Dashboard  

---

## Key Features

- Designed and implemented an end-to-end ETL pipeline using SQL  
- Built a dimensional data model (Star Schema)  
- Created fact tables (transactional + cumulative)  
- Implemented Slowly Changing Dimensions (SCD Type 2 & Type 3)  
- Performed data cleaning, validation, and transformation  
- Developed business-focused analytical queries  
- Built Tableau dashboards for visualization and insights  

---

## Data Sources

- **amazon_orders.csv** — order transaction data  
- **amazon_delivery.csv** — delivery and logistics data  

---

## Business Questions

This system is designed to answer key business questions such as:

- Which states generate the highest revenue?  
- Which states have the highest order volume?  
- What is the average order value by state?  
- How does revenue change over time?  
- How do delivery metrics impact overall performance?  

---

## Business Impact

This project enables actionable business insights:

- Identified top-performing states contributing the majority of revenue  
- Revealed differences between high order volume vs high revenue regions  
- Enabled tracking of customer lifetime value using cumulative fact tables  
- Provided visibility into delivery performance and operational efficiency  
- Improved ability to analyze trends and support data-driven decisions  

---

## Why This Project Matters

In real-world organizations, raw transactional data is often fragmented and difficult to analyze directly.

This project demonstrates the ability to:

- Design scalable and maintainable data models  
- Build reliable ETL pipelines  
- Transform raw data into structured analytics layers  
- Generate insights that support business decision-making  

These are core skills required for **Data Analyst, BI Engineer, and Data Engineer roles**.

---

## Tech Stack

- SQL  
- PostgreSQL (or similar relational database)  
- Tableau  
- Data Warehousing concepts (Star Schema, SCD, Fact/Dimension modeling)  

---

## Project Structure

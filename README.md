# Amazon Order & Revenue Data Warehouse

## Overview
This project builds a complete end-to-end data warehouse using Amazon order and delivery data. It transforms raw transactional data into a structured analytics system for business intelligence and decision-making.

## Architecture
Data pipeline:
Source → Staging → Clean Tables → Dimensions → Fact Tables → BI Dashboard

## Key Features
- ETL pipeline using SQL
- Dimensional modeling (Star Schema)
- Fact tables (transactional + cumulative)
- Slowly Changing Dimensions (SCD Type 2 & 3)
- Data cleaning and validation
- Business KPI queries
- Tableau dashboard for visualization

## Data Sources
- amazon_orders.csv (order transactions)
- amazon_delivery.csv (delivery operations)

## Business Questions
- Which states generate the highest revenue?
- Which states have the highest order volume?
- What is the average order value by state?
- How does revenue change over time?
- How do delivery factors impact performance?

## Tech Stack
- SQL
- PostgreSQL (or similar)
- Tableau
- Data Warehousing concepts

## Project Structure
- /sql → ETL pipeline and queries
- /reports → project documentation

## Results
The system enables:
- Revenue analysis by region
- Order volume tracking
- Customer value insights
- Operational performance evaluation

## Author
Susan Jia

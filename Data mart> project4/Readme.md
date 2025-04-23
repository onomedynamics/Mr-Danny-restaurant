# project title
 Data Mart SQL Case Study
## Tools Used: SQL (MySQL), Data Warehousing Concepts
## Focus: 
Data transformation and analysis using star schema logic in SQL
# Use Case: Business Intelligence reporting for customer orders, sales analysis, and product trends

# project description
This project simulates a simplified Data Mart structure where multiple fact and dimension tables are queried to answer business-related questions

## key insights
Total sales and profit by month

Customer order frequency and value

Product-level performance metrics

Sales trends over time

## Readme content
# 📊 Data Mart SQL Case Study

This project demonstrates the use of SQL for extracting and analyzing insights from a simulated Data Mart, representing a simplified star schema used in business intelligence.

## 🧠 Objective

To use SQL to query structured data for:

- Sales analysis
- Customer segmentation
- Product performance
- Monthly trends

## 🛠️ Tools & Technologies

- SQL (MySQL / PostgreSQL compatible)
- Data Mart / Star Schema modeling
- Analytical functions & date operations

## 📂 Dataset Overview

Key tables include:

- `customer_orders`
- `product_hierarchy`
- `product_prices`
- `campaigns`
- `order_metrics`

## 📌 Key Questions Answered

- What are the total sales and profit by product and month?
- Which customers purchase most frequently?
- Which product categories drive the most revenue?
- How effective are different campaigns?

## 💡 Sample Query

-- sql
SELECT MONTH(order_date) AS month, 
       SUM(sales_amount) AS total_sales
FROM customer_orders
GROUP BY MONTH(order_date);

## 🧩 Skills Demonstrated
Data aggregation and joins

Date-based filtering and grouping

Analytical thinking using SQL

Building data mart-style queries for dashboards
## 


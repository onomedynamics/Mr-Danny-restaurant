# pizza-analysis
Pizza Runner is a fictional startup that delivers pizza via runners. The goal of this case study is to help the Pizza Runner team better understand and optimize their operations using data.

##  🍕 Pizza Runner SQL Case Study

This project is part of the 8-Week SQL Challenge by Danny Ma. It analyzes a fictional startup, Pizza Runner, which delivers pizzas to customers via freelance runners.

---

## 📌 Project Overview

Pizza Runner is a pizza delivery startup that wants to understand its business operations and optimize its delivery process. This SQL case study explores their dataset using various SQL techniques to extract insights from the raw data.

---

## 📂 Dataset

The dataset includes the following tables:

- `runners`: Information about delivery personnel
- `customer_orders`: Customer order details
- `runner_orders`: Delivery status and performance
- `pizza_names`: Pizza name reference
- `pizza_recipes`: Ingredients per pizza
- `pizza_toppings`: Topping ID reference

---

## 🎯 Business Questions Answered

The analysis aims to answer several key questions:

1. What are the most popular pizza types?
2. How many successful deliveries have each runner completed?
3. What are the average delivery times?
4. What are the most common pizza toppings?
5. How many pizzas were excluded or substituted in each order?

---

## 🛠️ Skills Used

- SQL Joins
- Aggregations
- CTEs (Common Table Expressions)
- Data cleaning
- Window functions
- Filtering and grouping

---

## How to Use

1. Clone the repository.
2. Load the SQL script `pizza_runner.sql` into your SQL environment (MySQL, PostgreSQL, etc.).
3. Run the queries found in each analysis section to reproduce the insights.

---

## 📈 Sample Query

```sql
-- Top 3 most popular pizzas
SELECT pn.pizza_name, COUNT(co.pizza_id) AS total_orders
FROM customer_orders co
JOIN pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY pn.pizza_name
ORDER BY total_orders DESC
LIMIT 3;


# project title : Databank
## project description
This SQL project analyzes Data Bank, a digital banking platform, focusing on customer transactions, node allocations, and balance trends. The goal is to derive insights into customer behavior, regional node distribution, and financial patterns to optimize operations and improve customer experience.

## Key Questions Explored:
Node Allocation: How many unique nodes exist, and how are customers distributed across regions?

Transaction Analysis: What are the deposit, withdrawal, and purchase trends?

Balance Trends: What is the monthly closing balance for each customer?

Growth Metrics: What percentage of customers increased their balance by more than 5%?

## 📂 README Content
📊 Database Schema
Tables:

customer_nodes: Tracks node allocations (customer_id, region_id, node_id, start_date, end_date).

customer_transactions: Records financial transactions (customer_id, txn_date, txn_type, txn_amount).

region: Contains region details (region_id, region_name).

🔧 SQL Techniques Used
✔ Window Functions (NTILE, FIRST_VALUE, LAST_VALUE)
✔ Common Table Expressions (CTEs) for multi-step calculations
✔ Date Functions (DATE_FORMAT, DATEDIFF)
✔ Aggregations (SUM, AVG, COUNT)
✔ Conditional Logic (CASE WHEN)

🚀 Key Insights
Node Allocation:

X unique nodes exist, with Region Y having the highest customer allocation.

Customers stay Z days on average before node reallocation.

Transactions:

Deposits dominate transaction types, totaling $.

B% of customers make >1 deposit + 1 purchase/withdrawal monthly.

Balance Trends:

Median closing balance: $.

D% of customers increased their balance by >5%.

📥 How to Run
Execute the SQL script in a PostgreSQL/MySQL database.

Modify date filters (e.g., WHERE txn_month = '2020-01') for specific periods.


-- 1. How many unique nodes are there on the Data Bank system?
SELECT COUNT(DISTINCT node_id)
FROM customer_nodes;

-- 2. What is the number of nodes per region?
SELECT 
  region_id,
  COUNT(DISTINCT node_id) AS number_of_nodes
FROM 
  customer_nodes
GROUP BY 
  region_id
ORDER BY 
  region_id;
  
-- 3. How many customers are allocated to each region?
 SELECT 
  c.region_id,
  COUNT(DISTINCT customer_id) AS number_of_customers,r.region_name
FROM 
  customer_nodes c JOIN region r ON  r.region_id=c.region_id
GROUP BY 
  c.region_id,r.region_name
ORDER BY 
  c.region_id;
  
  -- 4.  How many days on average are customers reallocated to a different node?
  SELECT 
  ROUND(AVG(DATEDIFF(end_date, start_date)), 1) AS avg_days_on_node
FROM 
  customer_nodes
WHERE 
  end_date IS NOT NULL;

-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
WITH node_durations AS (
  SELECT 
    region_id,
    DATEDIFF(end_date, start_date) AS days_on_node
  FROM 
    customer_nodes
  WHERE 
    end_date IS NOT NULL
),
ranked_durations AS (
  SELECT 
    region_id,
    days_on_node,
    NTILE(100) OVER (PARTITION BY region_id ORDER BY days_on_node) AS percentile_rank
  FROM 
    node_durations
)
SELECT 
  region_id,
  MAX(CASE WHEN percentile_rank = 50 THEN days_on_node END) AS median_days,
  MAX(CASE WHEN percentile_rank = 80 THEN days_on_node END) AS p80_days,
  MAX(CASE WHEN percentile_rank = 95 THEN days_on_node END) AS p95_days
FROM 
  ranked_durations
GROUP BY 
  region_id
ORDER BY 
  region_id;

-- 6. What is the unique count and total amount for each transaction type?
SELECT COUNT(DISTINCT customer_id) AS 'transaction count', txn_type,
SUM(txn_amount) AS 'total amount'
FROM customer_transactions
GROUP BY txn_type;

-- 7. What is the average total historical deposit counts and amounts for all customers?
 SELECT 
    AVG(deposit_count) AS avg_total_deposit_count,
    AVG(deposit_amount) AS avg_total_deposit_amount
FROM (
    SELECT 
        customer_id,
        COUNT(*) AS deposit_count,
        SUM(txn_amount) AS deposit_amount
    FROM customer_transactions
    WHERE txn_type = 'deposit'
    GROUP BY customer_id
) AS customer_deposits;

-- 8. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH txn_summary AS (
  SELECT 
    customer_id,
    DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
    SUM(txn_type = 'deposit') AS deposits,
    SUM(txn_type = 'purchase') AS purchases,
    SUM(txn_type = 'withdrawal') AS withdrawals
  FROM 
    customer_transactions
  GROUP BY 
    customer_id, txn_month
)

SELECT 
  txn_month,
  COUNT(DISTINCT customer_id) AS qualifying_customers
FROM 
  txn_summary
WHERE 
  deposits > 1
  AND (purchases >= 1 OR withdrawals >= 1)
GROUP BY 
  txn_month
ORDER BY 
  txn_month;


-- 9. What is the closing balance for each customer at the end of the month?
WITH adjusted_txns AS (
  SELECT
    customer_id,
    DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
    CASE 
      WHEN txn_type = 'deposit' THEN txn_amount
      WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
      ELSE 0
    END AS adjusted_amount,
    txn_date
  FROM customer_transactions
),
monthly_balances AS (
  SELECT
    customer_id,
    txn_month,
    SUM(adjusted_amount) AS net_change_in_month
  FROM adjusted_txns
  GROUP BY customer_id, txn_month
),
running_totals AS (
  SELECT 
    customer_id,
    txn_month,
    SUM(net_change_in_month) OVER (
      PARTITION BY customer_id
      ORDER BY txn_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS closing_balance
  FROM monthly_balances
)

SELECT 
  customer_id,
  txn_month,
  closing_balance
FROM 
  running_totals
ORDER BY 
  customer_id,
  txn_month;

-- 10. What is the percentage of customers who increase their closing balance by more than 5%?
 WITH adjusted_txns AS (
  SELECT
    customer_id,
    DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
    CASE 
      WHEN txn_type = 'deposit' THEN txn_amount
      WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
      ELSE 0
    END AS adjusted_amount
  FROM customer_transactions
),
monthly_balance AS (
  SELECT
    customer_id,
    txn_month,
    SUM(adjusted_amount) AS net_change
  FROM adjusted_txns
  GROUP BY customer_id, txn_month
),
running_balance AS (
  SELECT
    customer_id,
    txn_month,
    SUM(net_change) OVER (
      PARTITION BY customer_id
      ORDER BY txn_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS closing_balance
  FROM monthly_balance
),
first_last_balance AS (
  SELECT
    customer_id,
    FIRST_VALUE(closing_balance) OVER (PARTITION BY customer_id ORDER BY txn_month) AS start_balance,
    LAST_VALUE(closing_balance) OVER (PARTITION BY customer_id ORDER BY txn_month 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS end_balance
  FROM running_balance
),
final_metrics AS (
  SELECT DISTINCT
    customer_id,
    start_balance,
    end_balance,
    CASE 
      WHEN start_balance > 0 THEN ROUND((end_balance - start_balance) / start_balance * 100, 2)
      ELSE NULL
    END AS pct_change
  FROM first_last_balance
)

SELECT 
  COUNT(*) AS total_customers,
  SUM(pct_change > 5) AS increased_customers,
  ROUND(SUM(pct_change > 5) / COUNT(*) * 100, 1) AS pct_increased
FROM final_metrics;

-- end of project

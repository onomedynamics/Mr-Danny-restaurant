USE data_mart;

-- 1. convert the week date text to normal date format
SELECT STR_TO_DATE('week_date', '%d-%m-%Y') AS converted_date
FROM weekly_sales;

ALTER TABLE weekly_sales
MODIFY COLUMN week_date DATE;

SHOW CREATE table weekly_sales;
-- 2. Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
SELECT
    week_date,
    FLOOR((DAYOFYEAR(week_date) - 1) / 7) + 1 AS week_number
FROM
    weekly_sales;
    
 -- 3.Add a month_number with the calendar month for each week_date value as the 3rd column
SELECT
    week_date,
    FLOOR((DAYOFYEAR(week_date) - 1) / 7) + 1 AS week_number,
    MONTH(week_date) AS month_number
FROM
    weekly_sales;
    
-- 4. Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

   SELECT
    week_date,
    FLOOR((DAYOFYEAR(week_date) - 1) / 7) + 1 AS week_number,
    MONTH(week_date) AS month_number,
    YEAR(week_date) AS calendar_year
FROM
    weekly_sales;

-- 5. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
SELECT
    week_date,
    FLOOR((DAYOFYEAR(week_date) - 1) / 7) + 1 AS week_number,
    MONTH(week_date) AS month_number,
    YEAR(week_date) AS calendar_year,
    segment,
    CASE 
        WHEN segment = 1 THEN '18-24'
        WHEN segment = 2 THEN '25-34'
        WHEN segment = 3 THEN '35-44'
        WHEN segment = 4 THEN '45-54'
        WHEN segment = 5 THEN '55+'
        ELSE 'Unknown' -- In case the segment value doesn't match the expected numbers
    END AS age_band
FROM
    weekly_sales;
    
-- 6. Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
ALTER TABLE weekly_sales
ADD COLUMN age_band VARCHAR(20) AFTER segment;

-- then lets populate the newly created column (age_band)
UPDATE weekly_sales
SET age_band = CASE
  WHEN segment LIKE '1%' THEN 'Young Adults'
  WHEN segment LIKE '2%' THEN 'Middle Aged'
  WHEN segment LIKE '3%' THEN 'Seniors'
  ELSE 'Unknown'
END;

-- 7. Add a new demographic column using the following mapping for the first letter in the segment values:
-- step 1 add a new column demographic
ALTER TABLE weekly_sales
ADD COLUMN demographic VARCHAR(20) AFTER age_band;

-- populate the new demographic column
UPDATE weekly_sales
SET demographic= CASE
	WHEN segment LIKE 'c%' THEN 'couples'
    WHEN segment LIKE 'F%' THEN 'families'
    ELSE 'unknown'
    END ;

-- 8. Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
UPDATE weekly_sales
SET segment = 'Unknown'
WHERE segment IS NULL OR TRIM(segment) = '';

-- for age_band
UPDATE weekly_sales
SET age_band = 'Unknown'
WHERE age_band IS NULL OR TRIM(age_band) = '';

-- for demographic
UPDATE weekly_sales
SET demographic = 'Unknown'
WHERE demographic IS NULL OR TRIM(demographic) = '';

-- 9 Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record
ALTER TABLE weekly_sales
ADD COLUMN avg_transaction DECIMAL(10,2);

UPDATE weekly_sales
SET avg_transaction = ROUND(sales / transactions, 2);

-- 2. DATA EXPLORATION
-- 1.  What day of the week is used for each week_date value?
-- To find the day of the week for each week_date value in the weekly_sales table
--  Query to check day of week per week_date
SELECT DISTINCT
  week_date,
  DAYNAME(week_date) AS day_of_week
FROM weekly_sales
ORDER BY week_date;

-- 2. What range of week numbers are missing from the dataset?
-- i cant do it now

-- 3. How many total transactions were there for each year in the dataset?
SELECT 
  YEAR(week_date) AS sales_year,
  SUM(transactions) AS total_transactions
FROM weekly_sales
GROUP BY sales_year
ORDER BY sales_year;

-- 4. What is the total sales for each region for each month?
SELECT 
  lower(region),
  DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
  SUM(sales) AS total_sales
FROM weekly_sales
GROUP BY region, sales_month
ORDER BY region, sales_month;

-- 5. What is the total count of transactions for each platform
SELECT 
  platform,
  SUM(transactions) AS total_transactions
FROM weekly_sales
GROUP BY platform
ORDER BY total_transactions DESC;

-- 6. What is the percentage of sales for Retail vs Shopify for each month?
WITH monthly_sales AS (
  SELECT 
    DATE_FORMAT(week_date, '%Y-%m') AS sales_month,
    platform,
    SUM(sales) AS total_sales
  FROM weekly_sales
  GROUP BY sales_month, platform
),
total_monthly_sales AS (
  SELECT 
    sales_month,
    SUM(total_sales) AS monthly_total
  FROM monthly_sales
  GROUP BY sales_month
)

SELECT 
  ms.sales_month,
  ms.platform,
  ms.total_sales,
  tm.monthly_total,
  ROUND(ms.total_sales / tm.monthly_total * 100, 2) AS pct_of_month_sales
FROM monthly_sales ms
JOIN total_monthly_sales tm
  ON ms.sales_month = tm.sales_month
ORDER BY ms.sales_month, ms.platform;

-- 7. What is the percentage of sales by demographic for each year in the dataset?
WITH yearly_sales AS (
  SELECT 
    YEAR(week_date) AS sales_year,
    demographic,
    SUM(sales) AS total_sales
  FROM weekly_sales
  GROUP BY sales_year, demographic
),
total_yearly_sales AS (
  SELECT 
    sales_year,
    SUM(total_sales) AS yearly_total
  FROM yearly_sales
  GROUP BY sales_year
)

SELECT 
  ys.sales_year,
  ys.demographic,
  ys.total_sales,
  tys.yearly_total,
  ROUND(ys.total_sales / tys.yearly_total * 100, 2) AS pct_of_year_sales
FROM yearly_sales ys
JOIN total_yearly_sales tys
  ON ys.sales_year = tys.sales_year
ORDER BY ys.sales_year, ys.demographic;

-- 8. Which age_band and demographic values contribute the most to Retail sales?
SELECT 
  age_band,
  demographic,
  SUM(sales) AS total_retail_sales
FROM weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY total_retail_sales DESC
LIMIT 1;

-- 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
-- The avg_transaction column is calculated per row as sales / transactions. So if you average all the avg_transaction values across rows, you're doing a row-based average, not a weighted average.

-- This can be inaccurate, especially if transaction volumes vary significantly across rows.

SELECT
  platform,
  YEAR(week_date) AS sales_year,
  ROUND(SUM(sales) / SUM(transactions), 2) AS avg_transaction_size
FROM weekly_sales
GROUP BY platform, YEAR(week_date)
ORDER BY sales_year, platform;



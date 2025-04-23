CREATE DATABASE pizza_runner;
USE pizza_runner;

CREATE TABLE runners (runner_id INT, registration_date DATE);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);  
INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', 'null', '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  
  CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
  CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  
  DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  UPDATE customer_orders
  SET exclusions= 0
  WHERE exclusions = NULL;
  SELECT* FROM customer_orders;
  
-- data cleaning
-- 1. create a clean copy of the table

CREATE TABLE clean_customer_orders AS
SELECT * FROM customer_orders;

-- 2. convert 'null' and empty () strings into proper NULL values
UPDATE clean_customer_orders
SET exclusions = NULL
WHERE exclusions IS NULL OR TRIM(LOWER(exclusions)) = 'null' OR TRIM(exclusions) = '';

UPDATE clean_customer_orders
SET extras = NULL
WHERE extras IS NULL OR TRIM(LOWER(extras)) = 'null' OR TRIM(extras) = '';

-- 3. remove  exact duplicates rows, we achieved this with common table expressions CTEs
WITH ranked_orders AS (
  SELECT *, 
         ROW_NUMBER() OVER (PARTITION BY order_id, customer_id, pizza_id, exclusions, extras, order_time ORDER BY order_id) AS rn
  FROM clean_customer_orders
)
DELETE FROM clean_customer_orders
WHERE (order_id, customer_id, pizza_id, exclusions, extras, order_time) IN (
  SELECT order_id, customer_id, pizza_id, exclusions, extras, order_time
  FROM ranked_orders
  WHERE rn > 1
);

SELECT * FROM clean_customer_orders;

-- 1. how many pizzas were ordered 
SELECT count(order_id) AS pizza_orders
FROM clean_customer_orders
;

-- How many unique customer orders were made?
SELECT DISTINCT order_id
FROM clean_customer_orders;

SELECT COUNT(DISTINCT order_id) AS unique_customer_orders
FROM clean_customer_orders;

-- we have 10 unique orders

-- 3. How many successful orders were delivered by each runner?
SELECT runner_id, count(*) AS 'successful deliveries'
FROM runner_orders
WHERE cancellation IS NULL OR cancellation= ''
GROUP BY runner_id;


-- 4. How many of each type of pizza was delivered?
SELECT pizza_name,count(*) AS 'delivered pizza'
FROM pizza_names
GROUP BY pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id,order_id,pizza_name
FROM
(SELECT
 co.order_id,
co.customer_id, 
pn.pizza_name,
ROW_NUMBER () OVER (PARTITION BY pizza_name,customer_id ORDER BY customer_id) AS rn
FROM customer_orders co JOIN
pizza_names pn ON 
co.pizza_id=pn.pizza_id) AS ranked 
WHERE rn=1;

-- 6.  What was the maximum number of pizzas delivered in a single order?
SELECT 
  order_id,
  COUNT(*) AS pizza_count
FROM customer_orders
GROUP BY order_id
ORDER BY pizza_count DESC
LIMIT 1;

-- 7.  For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
  co.customer_id,
  SUM(CASE 
        WHEN (co.exclusions IS NOT NULL AND co.exclusions <> '' AND co.exclusions <> 'null') 
          OR (co.extras IS NOT NULL AND co.extras <> '' AND co.extras <> 'null') 
        THEN 1 ELSE 0 
      END) AS pizzas_with_changes,
  SUM(CASE 
        WHEN (co.exclusions IS NULL OR co.exclusions = '' OR co.exclusions = 'null') 
          AND (co.extras IS NULL OR co.extras = '' OR co.extras = 'null') 
        THEN 1 ELSE 0 
      END) AS pizzas_without_changes
FROM clean_customer_orders co
JOIN runner_orders ro ON co.order_id = ro.order_id
WHERE ro.cancellation IS NULL OR ro.cancellation IN ('', 'null')
GROUP BY co.customer_id;

-- 8.  How many pizzas were delivered that had both exclusions and extras?
SELECT count(*) AS 'pizza with both exclusions and extras'
FROM clean_customer_orders
WHERE exclusions != '' AND extras != '';

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
  HOUR(order_time) AS order_hour,
  COUNT(*) AS total_pizzas
FROM clean_customer_orders
GROUP BY order_hour
ORDER BY order_hour;

-- 10. What was the volume of orders for each day of the week?
SELECT DAY(order_time) AS order_day,
COUNT(*) AS 'total orders'
FROM clean_customer_orders
GROUP BY order_day
ORDER BY order_day
LIMIT 7;

SELECT 
  DAYNAME(order_time) AS day_of_week,
  COUNT(*) AS total_pizzas
FROM customer_orders
GROUP BY day_of_week
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');


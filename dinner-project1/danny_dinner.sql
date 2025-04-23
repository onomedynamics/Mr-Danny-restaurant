CREATE database dannys_dinner;
USE dannys_dinner;

CREATE TABLE sales (customer_id VARCHAR(5), order_date DATE,product_id INT );

CREATE TABLE menu (product_id INT, product_name VARCHAR (30), PRICE DECIMAL (10,2));
CREATE TABLE members(customer_id VARCHAR(5), join_date DATE);

INSERT INTO sales (customer_id,order_date,product_id)
		VALUES('A', '2021-01-01', '1'),
			  ('A', '2021-01-01', '2'),
			  ('A', '2021-01-07', '2'),
			  ('A', '2021-01-10', '3'),
			  ('A', '2021-01-11', '3'),
			  ('A', '2021-01-11', '3'),
			  ('B', '2021-01-01', '2'),
			  ('B', '2021-01-02', '2'),
			  ('B', '2021-01-04', '1'),
			  ('B', '2021-01-11', '1'),
			  ('B', '2021-01-16', '3'),
			  ('B', '2021-02-01', '3'),
			  ('C', '2021-01-01', '3'),
			  ('C', '2021-01-01', '3'),
			  ('C', '2021-01-07', '3');
   
 INSERT INTO menu (product_id,product_name,price)
		VALUES  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  
 INSERT INTO members(customer_id, join_date)
		VALUES  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- What is the total amount each customer spent at the restaurant
  SELECT DISTINCT product_id, product_name,price AS 'total amount'
  FROM menu
  LIMIT 5;
  
  -- how many days has each customer visited the restaurant
  SELECT s.customer_id, count(join_date) AS "days visited"
  FROM members me JOIN 
  sales s ON me.customer_id=s.customer_id
  GROUP BY customer_id;
  
 -- 3. What was the first item from the menu purchased by each customer?
SELECT customer_id, product_id, product_name, order_date
FROM (
    SELECT 
        s.customer_id,
        s.product_id,
        m.product_name,
        s.order_date,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date ASC) AS rn
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
) AS ranked
WHERE rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT DISTINCT
    m.product_name,
    COUNT(*) AS total_purchases
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY m.product_id, m.product_name
ORDER BY total_purchases DESC
LIMIT 3;
-- the most purchased item is ramen and it was purchased 32 times

-- 5. Which item was the most popular for each customer?

SELECT customer_id, product_name, total_purchases
FROM (
    SELECT 
        s.customer_id,
        m.product_name,
        COUNT(*) AS total_purchases,
        ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rn
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, s.product_id, m.product_name
) AS ranked
WHERE rn = 1;

-- 6. Which item was purchased first by the customer after they became a member?
SELECT customer_id,product_name,join_date
FROM 
(
SELECT s.customer_id,
s.order_date,
me.join_date,
m.product_name,
ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.customer_id ASC) AS rn
FROM sales s JOIN menu m 
USING (product_id) 
JOIN members me 
ON s.customer_id=me.customer_id) AS ranked
WHERE rn=1;

-- ANS: the first purchase by customer A after he became a member is curry .
-- the first purchase by customer B after he became a member is sushi .

-- 7. Which item was purchased just before the customer became a member?

SELECT customer_id, product_name, order_date
FROM (
    SELECT 
        s.customer_id,
        m.product_name,
        s.order_date,
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_id
            ORDER BY s.order_date DESC
        ) AS rn
    FROM sales s
    JOIN members me ON s.customer_id = me.customer_id
    JOIN menu m ON s.product_id = m.product_id
    WHERE s.order_date < me.join_date
) AS ranked
WHERE rn = 1;

-- curry was purchased by customer A before he became a member
-- sushi was purchased by customer B before he became a member

-- 8 What is the total items and amount spent for each member before they became a member?
 
 SELECT s.customer_id,
 count(*) AS 'total items',
 sum(m.price) as 'total spent'
 FROM sales S 
 JOIN menu m ON s.product_id=m.product_id
 JOIN members me ON s.customer_id=me.customer_id
 WHERE s.order_date < me.join_date
 GROUP BY s.customer_id
 ORDER BY s.customer_id;

-- customer A total items bought and amount spent before they became a member is 16 and 200
-- customer B total items bought and amount spent before they became a member is 24 and 320


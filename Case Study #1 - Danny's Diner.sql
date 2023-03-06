# 8 Week Challenge..

-- Case Study #1 - Danny's Diner.
-- https://8weeksqlchallenge.com/case-study-1/

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many 
--    points would each customer have?
-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points on all 
--    items,not just sushi - how many points do customer A and B have at the end of January?

-- **********************************************************************************************************************************
# Creating Database and table..

CREATE SCHEMA dannys_diner;
USE DANNYS_DINER;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INT
);

INSERT INTO sales (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
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
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
-- ***********************************************************************************************************************************
# Quering..

-- MASTER TABLE.. AS AN VIEW
CREATE VIEW MASTER_TABLE AS(
SELECT *
FROM SALES
LEFT JOIN MENU USING(product_id)
LEFT JOIN MEMBERS USING(customer_id));

select * from master_table;

-- 1. What is the total amount each customer spent at the restaurant?.
SELECT customer_id,SUM(price)
FROM SALES S 
INNER JOIN MENU USING(product_id)
GROUP BY CUSTOMER_ID ;

# WITH RESPECT TO MASTER_TABLE.
SELECT customer_id,SUM(price) FROM MASTER_TABLE GROUP BY customer_id;

-- 2.How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(DISTINCT order_date) 
FROM SALES
GROUP BY customer_id;

-- 3.What was the first item from the menu purchased by each customer?
WITH CTE AS(
			SELECT *,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS RN
			FROM SALES
			LEFT JOIN MENU USING(PRODUCT_ID))
SELECT customer_id,product_name FROM CTE WHERE RN = 1;

# WITH RESPECT TO MASTER_TABLE.
WITH CTE AS(
			SELECT *,ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS RN
			FROM MASTER_TABLE)
SELECT customer_id,product_name FROM CTE WHERE  RN =1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT customer_id, COUNT(product_id) AS COUNT 
FROM  MASTER_TA 
WHERE product_name = (SELECT product_name FROM MASTER_TA GROUP BY product_id ORDER BY COUNT(product_id) DESC LIMIT 1 )
GROUP BY customer_id;


-- 5. Which item was the most popular for each customer?
WITH CTE AS (
			SELECT customer_id,product_name,COUNT(product_name) AS COUNT,
			DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_name) DESC) AS DNRK 
			FROM MASTER_TABLE
			GROUP BY customer_id,product_name)
SELECT customer_id,product_name,COUNT FROM CTE WHERE DNRK =1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH CTE AS(
			SELECT customer_id,product_name,order_date,join_date,
			ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS RN
			FROM MASTER_TABLE
			WHERE datediff(order_date,join_date) >= 0)
SELECT customer_id,product_name FROM CTE WHERE RN = 1;

-- 7.Which item was purchased just before the customer became a member?
WITH CTE1 AS(
			WITH CTE AS(
						SELECT *,
						ROW_NUMBER() OVER(PARTITION BY customer_id) AS RN
						FROM MASTER_TABLE
						WHERE datediff(join_date,order_date) > 0 OR datediff(join_date,order_date) IS NULL)
			SELECT customer_id, product_name,
			ROW_NUMBER() OVER(PARTITION BY CUSTOMER_ID ORDER BY RN DESC) AS RN1
			FROM CTE 
			GROUP BY customer_id,product_name)
SELECT * FROM CTE1 WHERE RN1 = 1;

-- 8.What is the total items and amount spent for each member before they became a member?
SELECT DISTINCT customer_id, 
				COUNT(product_name) OVER(PARTITION BY customer_id) AS TOTAL_ITEMS,
                SUM(price) OVER(PARTITION BY customer_id) AS TOTAL_PRICE
FROM MASTER_TABLE
WHERE datediff(join_date,order_date) > 0 OR datediff(join_date,order_date) IS NULL;

# OR 
SELECT DISTINCT customer_id, COUNT(product_id), SUM(price)
FROM MASTER_TABLE
WHERE datediff(join_date,order_date) > 0 OR datediff(join_date,order_date) IS NULL
GROUP BY customer_id;

-- 9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
-- -how many points would each customer have?

WITH CTE AS (
			SELECT *, CASE
						WHEN product_name = 'sushi' THEN price*2
						ELSE price
						END AS NEW_PRICE
			FROM MASTER_TABLE)
SELECT DISTINCT customer_id, SUM(NEW_PRICE) OVER (PARTITION BY customer_id) AS TOTAL_POINT
FROM CTE;

-- 10.In the first week after a customer joins the program (including their join date) they earn 2x points
--  on all items, not just sushi - how many points do customer A and B have at the end of January?

# THE BELOW QUERY GIVES WEEKS FROM DATEDIFF FUNC..
SELECT *,ROUND(DATEDIFF(order_date,join_date)/7,0) AS WEEKS 
FROM MASTER_TABLE;

WITH CTE AS(
			SELECT *,ROUND(DATEDIFF(order_date,join_date)/7,0) AS WEEKS,
			CASE
				WHEN ROUND(DATEDIFF(order_date,join_date)/7,0) = 1 THEN PRICE*2
				ELSE PRICE
				END AS NEW_PRICE
			FROM MASTER_TABLE)
SELECT DISTINCT customer_id, SUM(NEW_PRICE) OVER(PARTITION BY customer_id) AS TOTAL_PRICE
FROM CTE
WHERE customer_id IN('A','B');

# Bonus Questions 

-- 1. Recreating the table. 
SELECT customer_id,order_date,product_name,price,
IF( DATEDIFF(order_date,join_date) >=0, 'Y','N') AS `MEMBER`
FROM MASTER_TABLE;

-- 2. Rank All The Things.
WITH CTE AS (
			SELECT customer_id,order_date,product_name,price,
			IF( DATEDIFF(order_date,join_date) >=0, 'Y','N') AS `MEMBER`
			FROM MASTER_TABLE)
SELECT *,IF(MEMBER = 'Y',RANK() OVER(PARTITION BY customer_id,member ORDER BY order_date), NULL) AS RANKING
FROM CTE;

-- *********************************************************************************************************************************
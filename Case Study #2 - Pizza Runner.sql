-- Case Study #2 - Pizza Runner.
-- https://8weeksqlchallenge.com/case-study-2/

--  ***********************************************************************************************************************************************
--  DATA LOADING 

-- CREATING DATABASE AND TABLES..
CREATE SCHEMA pizza_runner;
USE pizza_runner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');

SELECT * FROM RUNNERS;

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
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
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

SELECT * FROM CUSTOMER_ORDERS;

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
  
SELECT * FROM RUNNER_ORDERS;

CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);

INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

SELECT * FROM PIZZA_NAMES;

CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

SELECT * FROM PIZZA_RECIPES;

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

SELECT * FROM PIZZA_TOPPINGS;

-- ***********************************************************************************************************************************************
-- DATA CLEANING..

SELECT * FROM pizza_names;             --  Pizza_names Table looks Good for Analysis 
SELECT * FROM pizza_toppings;          --  Pizza_toppings Table looks Good for Analysis 

SELECT * FROM pizza_recipes;  -- Not Normalized

DROP TABLE pizza_recipes; -- Delete Existing Table.

-- Creating New Table with Values...
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings_id INTEGER
);

INSERT INTO pizza_recipes
  (pizza_id, toppings_id)
VALUES 
(1,1),
(1,2),
(1,3),
(1,4),
(1,5),
(1,6),
(1,8),
(1,10),
(2,4),
(2,6),
(2,7),
(2,9),
(2,11),
(2,12);

SELECT * FROM pizza_recipes;           --  Pizza_Recipes Table looks Good for Analysis 

SELECT * FROM runners;                 --  Runner Table looks Good for Analysis 

SELECT * FROM runner_orders;
DESCRIBE runner_orders;                -- Pick up time in text, -- need to update into datetime.

SET SQL_SAFE_UPDATES = 0 ;

UPDATE runner_orders
SET pickup_time = NULL WHERE pickup_time = 'NULL';       -- Converted all empty cells as 'null' to Null values.

ALTER TABLE runner_orders
MODIFY COLUMN pickup_time DATETIME;                      -- Converted pickup time to Datetime Format.

UPDATE runner_orders
SET distance = NULL WHERE distance = 'NULL';             -- Converted all empty cells as 'null' to Null values.

UPDATE runner_orders
SET duration = NULL WHERE duration = 'NULL';             -- Converted all empty cells as 'null' to Null values.

select * from runner_orders where cancellation = '';

UPDATE runner_orders
SET cancellation = NULL WHERE cancellation = 'NULL' or cancellation = '' ; 

SELECT * FROM runner_orders;                              --  Runner_orders Table looks Good for Analysis.

SELECT * FROM customer_orders;
DESCRIBE customer_orders;

UPDATE customer_orders
SET exclusions = NULL WHERE exclusions = 'NULL' or exclusions  = '' ; 

UPDATE customer_orders
SET extras = NULL WHERE extras = 'NULL' or extras  = '' ; 

SELECT * FROM customer_orders;                           --  Customer_orders Table looks Good for Analysis 

--  ***********************************************************************************************************************************************
--  DATA EXPORATION..

/*
--A. Pizza Metrics.
1.How many pizzas were ordered?
2.How many unique customer orders were made?
3.How many successful orders were delivered by each runner?
4.How many of each type of pizza was delivered?
5.How many Vegetarian and Meatlovers were ordered by each customer?
6.What was the maximum number of pizzas delivered in a single order?
7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
8.How many pizzas were delivered that had both exclusions and extras?
9.What was the total volume of pizzas ordered for each hour of the day?
10.What was the volume of orders for each day of the week?
*/

-- 1.How many pizzas were ordered?
SELECT COUNT(pizza_id) AS TOTAL_PIZZAS 
FROM customer_orders;

-- 2.How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS UNIQUE_ORDERS
FROM customer_orders;

-- 3.How many successful orders were delivered by each runner?
SELECT runner_id,COUNT(order_id) AS ORDERS_COUNT
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4.How many of each type of pizza was delivered?
SELECT DISTINCT(C.pizza_id),COUNT(C.pizza_id) AS PIZZA_COUNT
FROM customer_orders C
LEFT JOIN runner_orders R USING(order_id)
WHERE R.cancellation IS NULL
GROUP BY C.pizza_id;

-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
SELECT DISTINCT(P.pizza_name),COUNT(C.pizza_id) AS PIZZA_COUNT
FROM customer_orders C
LEFT JOIN pizza_names P USING(pizza_id)
GROUP BY P.pizza_name;

-- 6.What was the maximum number of pizzas delivered in a single order?
SELECT DISTINCT(order_id),COUNT(pizza_id) AS PIZZA_COUNT
FROM customer_orders 
GROUP BY order_id
ORDER BY PIZZA_COUNT DESC LIMIT 1;

-- 7.For each customer, 
--   how many delivered pizzas had at least 1 change and how many had no changes?
SELECT C.customer_id,COUNT(C.pizza_id) AS PIZZA_COUNT
FROM customer_orders C
LEFT JOIN runner_orders R ON R.order_id = C.order_id  AND R.cancellation IS NULL
WHERE exclusions IS NOT NULL OR extras IS NOT NULL
GROUP BY C.customer_id;

-- 8.How many pizzas were delivered that had both exclusions and extras?
SELECT COUNT(C.pizza_id) AS PIZZA_COUNT
FROM customer_orders C
LEFT JOIN runner_orders R ON R.order_id = C.order_id  AND R.cancellation IS NULL
WHERE exclusions IS NOT NULL AND extras IS NOT NULL;

-- 9.What was the total volume of pizzas ordered for each hour of the day?
SELECT COUNT(pizza_id) AS TOTAL_ORDERED_PIZZA, 
       COUNT(DISTINCT DAY(order_time)) AS NUMBER_OF_DAYS,
	   ROUND(COUNT(pizza_id)/COUNT(DISTINCT DAY(order_time)),2) AS PIZZA_ORDERED_PER_HOUR
FROM customer_orders;

-- 10.What was the volume of orders for each day of the week?
SELECT DATE(order_time),COUNT(pizza_id) AS PIZZA_COUNT
FROM customer_orders
GROUP BY 1;

--  ***********************************************************************************************************************************************


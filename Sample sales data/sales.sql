CREATE DATABASE sample_sales_db;
USE sample_sales_db;

CREATE TABLE sales (
order_number INT,
quantity_ordered INT,
price_each DECIMAL (10,2),
order_line_number INT,
sales DECIMAL (10,2),
order_date VARCHAR(30),
status varchar(50), 
qtr_id INT,
month_id INT,
year_id INT,
product_line VARCHAR(100),
msrp INT,
product_code VARCHAR(50),
customer_name VARCHAR(150),
phone VARCHAR(50),
addressline1 TEXT,
addressline2 TEXT,
city VARCHAR(100),
state VARCHAR(100),
postal_code VARCHAR(20),
country VARCHAR(100),
territory VARCHAR(100),
contact_lastname VARCHAR(100),
contact_firstname VARCHAR(100),
deal_size varchar(50)
);

describe sales;

SELECT order_date,
       STR_TO_DATE(order_date, '%c/%e/%Y %H:%i') AS converted_date
FROM sales
LIMIT 10;

# Let us debug the dates that were not converted.

select order_date
from sales
where order_date like '%-%'
limit 10;

select order_date
from sales
where order_date like '%/%'
limit 10;

SELECT order_date,
       STR_TO_DATE(order_date, '%c/%e/%Y %H:%i') AS test_slash
FROM sales
WHERE order_date LIKE '%/%'
LIMIT 10;

SELECT order_date,
       STR_TO_DATE(order_date, '%c-%e-%Y %H:%i') AS test_dash
FROM sales
WHERE order_date LIKE '%-%'
LIMIT 10;

UPDATE sales
SET order_date = TRIM(order_date);

#Let us normalize the separators
UPDATE sales
SET order_date = REPLACE(order_date, '-', '/');
# We also fix the inconsistent timing
UPDATE sales
SET order_date = 
    REPLACE(order_date, ' 0:', ' 00:');
    
UPDATE sales
SET orderdate_clean =
STR_TO_DATE(order_date, '%c/%e/%Y %H:%i');

SELECT order_date, orderdate_clean
FROM sales
WHERE orderdate_clean IS NULL;

select order_date, orderdate_clean
from sales;

SELECT 
    order_date,
    orderdate_clean,
    DATE_FORMAT(orderdate_clean, '%Y-%m-%d %H:%i:%s') AS formatted
FROM sales
LIMIT 10;

SELECT
	SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END) AS ordernumber_nulls,
    SUM(CASE WHEN quantity_ordered IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN price_each IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN order_line_number IS NULL THEN 1 ELSE 0 END) AS orderline_nulls,
    SUM(CASE WHEN sales IS NULL THEN 1 ELSE 0 END) AS sales_nulls,
    SUM(CASE WHEN orderdate_clean IS NULL THEN 1 ELSE 0 END) AS date_nulls,
    SUM(CASE WHEN deal_size IS NULL THEN 1 ELSE 0 END) AS deal_nulls,
    SUM(CASE WHEN contact_lastname IS NULL THEN 1 ELSE 0 END) AS lastname_nulls,
    SUM(CASE WHEN contact_firstname IS NULL THEN 1 ELSE 0 END) AS firstname_nulls,
    SUM(CASE WHEN territory IS NULL THEN 1 ELSE 0 END) AS territory_nulls,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS country_nulls,
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS state_nulls,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS city_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_nulls
FROM sales;
    
SELECT
	SUM(CASE WHEN TRIM(order_number) = '' THEN 1 ELSE 0 END) AS ordernumber_empty,
    SUM(CASE WHEN TRIM(quantity_ordered) = '' THEN 1 ELSE 0 END) AS quantity_empty,
    SUM(CASE WHEN TRIM(price_each) = '' THEN 1 ELSE 0 END) AS price_empty,
    SUM(CASE WHEN TRIM(order_line_number) = ''THEN 1 ELSE 0 END) AS orderline_empty,
    SUM(CASE WHEN TRIM(sales) = '' THEN 1 ELSE 0 END) AS sales_empty,
    SUM(CASE WHEN TRIM(orderdate_clean) = '' THEN 1 ELSE 0 END) AS date_empty,
    SUM(CASE WHEN TRIM(deal_size) = '' THEN 1 ELSE 0 END) AS deal_empty,
    SUM(CASE WHEN TRIM(contact_lastname) = '' THEN 1 ELSE 0 END) AS lastname_empty,
    SUM(CASE WHEN TRIM(contact_firstname) = ''THEN 1 ELSE 0 END) AS firstname_empty,
    SUM(CASE WHEN TRIM(territory) = '' THEN 1 ELSE 0 END) AS territory_empty,
    SUM(CASE WHEN TRIM(country) = '' THEN 1 ELSE 0 END) AS country_empty,
    SUM(CASE WHEN TRIM(state) = '' THEN 1 ELSE 0 END) AS state_empty,
    SUM(CASE WHEN TRIM(city) = '' THEN 1 ELSE 0 END) AS city_empty,
    SUM(CASE WHEN TRIM(customer_name) = '' THEN 1 ELSE 0 END) AS customer_empty
FROM sales;

SELECT order_number, COUNT(*)
FROM sales
GROUP BY order_number
HAVING COUNT(*) > 1;

SELECT *
FROM sales
WHERE order_number IN (
	SELECT order_number
    FROM sales
    GROUP BY order_number
    HAVING COUNT(*) > 1
)
ORDER BY order_number;



SELECT *
FROM sales
WHERE sales < 0;

SELECT *
FROM sales
WHERE quantity_ordered <= 0;

SELECT *
FROM sales
WHERE price_each <= 0;

SELECT MIN(orderdate_clean), MAX(orderdate_clean)
FROM sales;

SELECT DISTINCT status
FROM sales;

# Revenue concentration
SELECT 
	SUM(sales) as total_revenue
FROM sales;

# monthly revenue trend
SELECT
	YEAR(orderdate_clean) AS year,
    MONTH(orderdate_clean) AS month,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY YEAR(orderdate_clean), MONTH(orderdate_clean)
ORDER BY year, month;

#Month with the highest revenue
SELECT
	YEAR(orderdate_clean) AS year,
    MONTH(orderdate_clean) AS month,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY YEAR(orderdate_clean), MONTH(orderdate_clean)
ORDER BY total_revenue DESC
LIMIT 1;

# Top 5 months
SELECT
	YEAR(orderdate_clean) AS year,
    MONTH(orderdate_clean) AS month,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY YEAR(orderdate_clean), MONTH(orderdate_clean)
ORDER BY total_revenue DESC
LIMIT 5;

# Countryrevenue ranking
SELECT
	country,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY country
ORDER BY total_revenue DESC;

# Average order value
SELECT
	country, 
    SUM(sales)/COUNT(*) AS avg_order_value,
    COUNT(*) AS total_orders
FROM sales
GROUP BY country
ORDER BY avg_order_value DESC;

#product revenue ranking
SELECT
	product_line,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

# average product order revenue
SELECT 
	product_line,
    SUM(sales)/COUNT(*) AS avg_product_order_value,
    COUNT(*) AS total_orders
FROM sales
GROUP BY product_line
ORDER BY avg_product_order_value DESC;

# Top customers by revenue
SELECT
	customer_name,
    SUM(sales) AS total_revenue,
    COUNT(*) AS total_orders
FROM sales
GROUP BY customer_name
ORDER BY total_revenue DESC;

# Customer revenue 
SELECT
	customer_name,
    SUM(sales) AS total_revenue,
    CASE
		WHEN SUM(sales) >= 600000 THEN 'VIP Customer'
        ELSE 'Regular Customer'
	END AS customer_segment
FROM sales
GROUP BY customer_name
ORDER BY total_revenue DESC;
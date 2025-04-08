--Retail Orders Data Analysis--

CREATE DATABASE retail_orders;

USE retail_orders;

SELECT *
FROM orders;


-- Find top 10 highest revenue generating product

SELECT TOP 10 product_id, SUM(sale_price) as sales
FROM orders
GROUP BY product_id
ORDER BY sales DESC;


-- Find top 5 highest selling products in each region

WITH CTE AS (
SELECT region, product_id, SUM(sale_price) AS sales
FROM orders
GROUP BY region, product_id
)
SELECT *
FROM (SELECT *, ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS row_num
FROM CTE) AS A
WHERE row_num <= 5;


-- Find month over month comparison for 2022 and 2023 sales

WITH cte AS(
SELECT YEAR(order_date) AS order_year,MONTH(order_date) AS order_month, SUM(sale_price) AS sales
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
	ROUND(SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END),2) AS sales_2022,
	ROUND(SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END),2)AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


-- For each category which month had highest sales

WITH cte AS(
SELECT category, FORMAT(order_date,'yyyy-MM') AS order_year_month, SUM(sale_price) AS sales
FROM orders
GROUP BY category,FORMAT(order_date,'yyyy-MM')
)
SELECT * FROM (
SELECT *, ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) as row_num
FROM cte) A
WHERE row_num = 1
ORDER BY sales;


-- Which sub-category had highest growth by profit in 2023 compare to 2022

WITH cte AS(
SELECT sub_category,YEAR(order_date) AS order_year, SUM(sale_price) AS sales
FROM orders
GROUP BY sub_category, YEAR(order_date)
),
cte2 AS(
SELECT sub_category,
	SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
	SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
)
SELECT TOP 1*, (sales_2023-sales_2022)/sales_2022*100 AS growth
FROM cte2
ORDER BY (sales_2023-sales_2022)/sales_2022*100 DESC;
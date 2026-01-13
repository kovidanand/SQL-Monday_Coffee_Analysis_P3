-- Monday Coffee Data Analysis

SELECT * FROM city;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM sales;

-- Report & Data Analysis

-- Q.1 Coffee Consumers Count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

SELECT 
    city_name,
	ROUND((population * 0.25)/1000000,2) AS coffee_consumer_in_millions,
	city_rank
FROM city
ORDER BY 2 DESC


-- Q.2 What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?


SELECT SUM(total) as total_revenue
FROM sales
WHERE 
     EXTRACT(YEAR FROM sale_date) = 2023
	 AND
     EXTRACT(QUARTER FROM sale_date) = 4


-- Per City Revenue

SELECT 
   ci.city_name,
   SUM(s.total) as total_revenue
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
WHERE 
     EXTRACT(YEAR FROM s.sale_date) = 2023
	 AND
     EXTRACT(QUARTER FROM s.sale_date) = 4
Group BY 1
ORDER BY 2 DESC


--Q.3 How many units of each coffee product have been sold?


SELECT 
  p.product_name,
  COUNT(s.sale_id) as Total_orders
FROM products as p
LEFT JOIN 
sales as s
ON s.product_id = p.product_id
group by 1
ORDER BY 2 DESC


 -- Q.4 What is the average sales amount per customer in each city?

SELECT 
   ci.city_name,
   SUM(s.total) as total_revenue,
   COUNT(DISTINCT s.customer_id) as Total_customers,
   ROUND(SUM(s.total):: NUMERIC
   /COUNT(DISTINCT s.customer_id),2):: NUMERIC AS Avg_sales_per_cus
FROM sales as s
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
Group BY 1
ORDER BY 2 DESC


--Q.5 Top Selling Products by City
--    What are the top 3 selling products in each city based on sales volume?

SELECT*
FROM
(
SELECT 
     ci.city_name,
	 p.product_name,
	 COUNT(s.sale_id) as Total_orders,
	 DENSE_RANK() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id)DESC) AS rank
FROM sales as s 
JOIN products as p 
ON s.product_id = p.product_id
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
GROUP BY 1,2
)
WHERE rank <= 3

--Q.6 Customer Segmentation by City
--    How many unique customers are there in each city who have purchased coffee products?

SELECT 
    ci.city_name,
	COUNT(DISTINCT s.customer_id) as Total_unique_cus
FROM sales as s
LEFT JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
JOIN products as p
ON p.product_id = s.product_id
GROUP BY 1


--Q7. Average Sale vs Rent
--    Find each city and their average sale per customer and avg rent per customer

WITH city_table
AS
(
SELECT 
     ci.city_name,
	 COUNT(DISTINCT  s.customer_id) AS Total_cus,
	 ROUND(SUM(s.total):: numeric
	 /COUNT(DISTINCT  s.customer_id),2)  :: numeric as Avg_sale_per_cus
FROM sales as s 
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
group by 1
ORDER BY 2  DESC
),
city_rent
AS
(
SELECT city_name, 
       estimated_rent
FROM city
)
SELECT
    cr.city_name,
	cr.estimated_rent,
	ct.Total_cus,
	ct.Avg_sale_per_cus,
	ROUND(cr.estimated_rent :: NUMERIC /ct.Total_cus,2) :: NUMERIC as avg_rent_per_cus
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 4 DESC



--Q.8 Monthly Sales Growth
--Sales growth rate: Calculate the percentage growth (or decline) in sales over different time 
--periods (monthly).
--by each city


WITH
monthly_sales
AS
(
SELECT 
     ci.city_name,
	 EXTRACT (MONTH FROM sale_date) as month,
	 EXTRACT (Year FROM sale_date) as year,
	 SUM(s.total) as Total_sale	 
FROM sales as s 
JOIN customers as c
ON c.customer_id = s.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
JOIN products as p 
ON p.product_id = s.product_id 
Group by 1,2,3
order by 1,3,2
),

growth_table
AS
(
SELECT
    city_name,
	month,
	year,
	total_sale as cr_month_sale,
	LAG(total_sale, 1) OVER(PARTITION BY city_name ORDER BY year, month) as last_month_sale
FROM monthly_sales
)

SELECT 
    city_name,
	month,
	year,
    cr_month_sale,
	last_month_sale,
	ROUND((cr_month_sale - last_month_sale):: numeric 
	/last_month_sale :: numeric * 100 , 2) AS growth_ratio

FROM growth_table
WHERE 
   last_month_sale IS NOT null


--Q.9 Market Potential Analysis
--Identify top 3 city based on highest sales, return city name, total sale, 
--total rent, total customers, estimated coffee consumer


WITH city_table
AS
(
SELECT 
     ci.city_name,
	 SUM(s.total) as Total_revenue,
	 COUNT(DISTINCT  s.customer_id) AS Total_cus,
	 ROUND(SUM(s.total):: numeric
	 /COUNT(DISTINCT  s.customer_id),2)  :: numeric as Avg_sale_per_cus
FROM sales as s 
JOIN customers as c
ON s.customer_id = c.customer_id
JOIN city as ci
ON ci.city_id = c.city_id
group by 1
ORDER BY 2  DESC
),
city_rent
AS
(
SELECT city_name, 
       estimated_rent,
	   ROUND((population * 0.25/1000000),2) as estimated_coffee_consumer_in_millions
FROM city
)
SELECT
    cr.city_name,
	ct.Total_revenue,
	cr.estimated_rent as total_rent,
	estimated_coffee_consumer_in_millions,
	ct.Total_cus,
	ct.Avg_sale_per_cus,
	ROUND(cr.estimated_rent :: NUMERIC /ct.Total_cus,2) :: NUMERIC as avg_rent_per_cus
FROM city_rent as cr
JOIN city_table as ct
ON cr.city_name = ct.city_name
ORDER BY 2 DESC
LIMIT 3





                                         --END OF THE PROJECT--


  




















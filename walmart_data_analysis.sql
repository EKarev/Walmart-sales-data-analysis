SELECT * FROM walmart;
-- Business problems
-- Q.1 FInd different payment method and number of transactions, number of quantity sold

SELECT 
	payment_method,
	COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;
-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category and AVG rating

SELECT * 
FROM
(	SELECT
	 branch, category, AVG(rating) as avg_rating,
	 RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY branch, category
 )
 WHERE rank = 1;
 
 -- Q.3 Identify the busiest day for each branch based on the number of transactions
 
 SELECT * 
 FROM
 	(SELECT
 	branch, 
	TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
	COUNT(*) AS num_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
 	FROM walmart
 	GROUP BY 1,2)
 WHERE rank = 1;

 -- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total quantity.

SELECT 
	payment_method,
	--COUNT(*) as no_payments,
	SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.5 Determine the average, minimum, maximum rating of each category for each city. 
-- List the city, average_rating,min_rating and max_rating.

SELECT
	category, city,
	AVG(rating) as avg_rating,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	RANK() OVER(PARTITION BY category ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY 1,2;

-- Q.6 Calculate the total profit for each category by considering total_profit according to quantity, price and profit margin. 
-- order from highest to lower profit

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total*profit_margin) as profit
FROM walmart
GROUP BY 1
ORDER BY 2 DESC;

-- Q.7 Determine the most common payment method for each branch

SELECT branch, payment_method
FROM
(	SELECT
	branch,
	payment_method,
	COUNT(payment_method) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) as rank
FROM walmart
GROUP BY 1,2
 )
 WHERE rank=1;
 
-- Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out which of the shift and number of invoices
SELECT branch, day_time, COUNT(invoice_id) as num_invoices
FROM
(
	SELECT 
	*,
	CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time
FROM walmart
)
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Q.9 Identify 5 branch with highest decrease ratio in revenue compare to last year 
-- (current year 2023 and last year 2022)

WITH 

revenue_2022
AS
	(	SELECT
				branch,
				SUM(total) as revenue
		FROM walmart
		WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
		GROUP BY 1
	),

revenue_2023
AS
	(	SELECT
				branch,
				SUM(total) as revenue
		FROM walmart
		WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
		GROUP BY 1
	)

SELECT 
	ls.branch, 
	ls.revenue as last_year_revenue, 
	cs.revenue as cr_year_revenue,
	ROUND((ls.revenue - cs.revenue)::numeric/ls.revenue::numeric * 100, 2) as decrease_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;
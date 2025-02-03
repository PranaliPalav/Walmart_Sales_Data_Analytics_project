 SELECT * FROM public.walmart;

--Q1. find different payment method and number of transactions, number of qty sold
SELECT 
	payment_method,
	count(*)  as no_transactions,
	sum(quantity) as qty_sold
FROM walmart
GROUP BY payment_method;


--Q2. Identify the highest-rated category in each branch, displaying the branch, category, AVG RATING
SELECT *
FROM
(
SELECT 
	branch,
	category,
	avg(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank=1;
 
-- Q.3 Identify the busiest day for each branch based on the number of transactions
SELECT *
FROM 
( 
SELECT 
	branch,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') AS day,
	COUNT(*) as no_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY count(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank=1;


--Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.
SELECT 
	payment_method,
	sum(quantity) as qty_sold
FROM walmart
GROUP BY payment_method;


--Q.5 determine the average , minimum and maximum rating of categoryfor each city.
--list the city , average , rating, min_rating and max_rating
SELECT
	city,
	category,
	min(rating) as min_rating,
	avg(rating) as avg_rating,
	max(rating) as max_rating
FROM walmart
GROUP BY city,2;


-- Q.6 Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.
SELECT 
	category,
	SUM(unit_price * quantity * profit_margin) AS profit_margin 
FROM walmart 
GROUP BY category;


-- Q.7 Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
SELECT 
branch,
payment_method
FROM 
(
	SELECT
	branch,
	payment_method,
	COUNT(*) as total_transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2
)
WHERE rank=1;

-- Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices
SELECT
	branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time))<12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	count(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

WITH revenue_2022
AS
(
	SELECT 
		branch, 
		sum(total) as revenue
	FROM public.walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) =2022
	GROUP BY 1
), 
revenue_2023
AS
(
	SELECT 
		branch, 
		sum(total) as revenue
	FROM public.walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) =2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as current_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/ 
		ls.revenue::numeric *100,
		2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN
revenue_2023 AS cs
ON ls.branch = cs.branch 
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC 
LIMIT 5


--10. Find the top 3 best-selling products in each branch
SELECT 
	category,
	branch
FROM
	(
	SELECT 
		category,
		branch,
		SUM(quantity),
		RANK() OVER(PARTITION BY branch ORDER BY SUM(quantity) DESC) as rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE rank<=3;

--11. Find the average spending per customer for each branch
SELECT
	branch,
	COUNT(distinct invoice_id) as id,
 	SUM(total)/COUNT(distinct invoice_id) as avg_spending
FROM walmart 
GROUP BY 1;


--12. Identify the most popular product category in each city
SELECT *
FROM 
	(
	SELECT 
		city,
		category,
		RANK() OVER(PARTITION BY CITY ORDER BY SUM(quantity) DESC)as rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE RANK=1;


--13. Find the least profitable product category in each branch
SELECT *
FROM 
	(
	SELECT 
		branch,
		category,
		RANK() OVER(PARTITION BY BRANCH ORDER BY SUM(total*profit_margin) ASC)as rank
	FROM walmart
	GROUP BY 1,2
	)
WHERE RANK=1;

--14. Find the average bill amount for each payment method
SELECT 
	payment_method,
	AVG(total) as bill_amt
FROM walmart
GROUP BY 1
ORDER BY bill_amt DESC;

--15. Find the percentage of transactions that used each payment method per branch
SELECT 
	payment_method,
	branch,
	ROUND(
		COUNT(*)*100.0/SUM(COUNT(*)) OVER (PARTITION BY BRANCH) ,2
		) AS percentage
FROM walmart
GROUP BY 1,2



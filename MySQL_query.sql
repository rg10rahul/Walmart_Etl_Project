CREATE DATABASE Walmart_analysis;
USE walmart_analysis;
SELECT * FROM walmart;

-- Find different payment methods, number of transactions, and quantity sold by payment method
SELECT payment_method, COUNT(*) AS payment_number, SUM(quantity) AS sold_quantity
FROM walmart 
GROUP BY payment_method;

-- Identify the highest-rated category in each branch
SELECT * 
FROM (
	SELECT 
	branch, category, AVG(rating) AS avg_rating,
	RANK()OVER (partition by branch ORDER BY AVG(rating) DESC) AS ranking
	FROM walmart 
	GROUP BY branch, category
) 
AS ranked_data 
WHERE ranking=1;

-- Identify the busiest day for each branch based on the number of transactions
SELECT 
	branch, day_name, no_transactions,ranking
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%Y-%m-%d')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK()OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_data
WHERE ranking = 1;

-- Calculate the total quantity of items sold per payment method
SELECT 
	payment_method, SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;

-- Determine the average, minimum, and maximum rating of categories for each city
SELECT 
	city, category, 
	AVG(rating) AS avg_rating, 
	MIN(rating) AS min_rating, 
	MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

-- Calculate the total profit for each category ranked from highest to lowest
SELECT 
	category, SUM(total*profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Determine the most common payment method for each branch
WITH cte 
AS
	(SELECT 
		branch, payment_method, COUNT(*) AS trans_total,
		RANK()OVER (partition by branch ORDER BY COUNT(*)DESC) AS ranking
		FROM walmart
		GROUP BY branch, payment_method
	)
SELECT branch, payment_method
FROM cte
WHERE ranking=1;

-- Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS day_time,
    COUNT(*) AS trans_num
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, trans_num DESC;

-- Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%Y-%m-%d')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%Y-%m-%d')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
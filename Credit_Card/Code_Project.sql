-- =====================================================================
-- SQL Script: credit_card_analysis_queries.sql
-- Description: Analytical queries on the Kaggle dataset 
-- "Analyzing Credit Card Spending Habits in India"
-- Source: https://www.kaggle.com/datasets/thedevastator/analyzing-credit-card-spending-habits-in-india
-- =====================================================================

-- 0. Preview all data
SELECT * FROM mytable;


---------------------------------------------------------------------------------
-- 1️⃣ Top 5 Cities by Credit Card Spending & Their % Contribution
---------------------------------------------------------------------------------
SELECT TOP 5 
    city,
    SUM(CAST(amount AS BIGINT)) AS total_sales,
    (SUM(CAST(amount AS BIGINT)) * 100.0 / SUM(SUM(CAST(amount AS BIGINT))) OVER ()) AS percentage_of_sales
FROM mytable
GROUP BY city
ORDER BY total_sales DESC;
-- This query finds total spend per city and computes each city’s share of overall spend.

---------------------------------------------------------------------------------
-- 2️⃣ Highest Spending Month for Each Card Type
---------------------------------------------------------------------------------
WITH monthly_spend AS (
    SELECT 
        card_type,
        DATEPART(YEAR, transaction_date) AS yr,
        DATEPART(MONTH, transaction_date) AS mn,
        SUM(amount) AS total_sale
    FROM mytable
    GROUP BY card_type, DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
)
SELECT card_type, yr, mn, total_sale
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY card_type ORDER BY total_sale DESC) AS rnk
    FROM monthly_spend
) ranked
WHERE rnk = 1;
-- This calculates monthly spend per card type, then picks the month with the highest spend.

---------------------------------------------------------------------------------
-- 3️⃣ Transaction When Cumulative Spend Crosses ₹ 10,00,000 per Card Type
---------------------------------------------------------------------------------
WITH cte AS (
    SELECT *,
           SUM(amount) OVER (PARTITION BY card_type ORDER BY transaction_date, transaction_id) AS cumulative_spend
    FROM mytable
)
SELECT *
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY card_type ORDER BY cumulative_spend) AS rnk
    FROM cte
    WHERE cumulative_spend > 1000000
) t
WHERE rnk = 1;
-- Explanation:
-- - Calculates running total of spend per card_type in chronological order.
-- - Finds the first transaction where cumulative spend exceeds 10 lakh (1,000,000).

---------------------------------------------------------------------------------
-- 4️⃣ City with Lowest Total Spend for Gold Card Type
---------------------------------------------------------------------------------
SELECT TOP 1 
    city,
    SUM(amount) AS total_spend_gold
FROM mytable
WHERE card_type = 'Gold'
GROUP BY city
ORDER BY total_spend_gold ASC;
-- This finds which city has the lowest total spend among Gold card transactions.

---------------------------------------------------------------------------------
-- 5️⃣ Highest & Lowest Expense Type per City
---------------------------------------------------------------------------------
WITH city_expense AS (
    SELECT city, exp_type, SUM(amount) AS sales
    FROM mytable
    GROUP BY city, exp_type
),
ranked AS (
    SELECT city, exp_type, sales,
           RANK() OVER (PARTITION BY city ORDER BY sales DESC) AS rnk_high,
           RANK() OVER (PARTITION BY city ORDER BY sales ASC) AS rnk_low
    FROM city_expense
)
SELECT city,
       MAX(CASE WHEN rnk_high = 1 THEN exp_type END) AS highest_expense_type,
       MAX(CASE WHEN rnk_low = 1 THEN exp_type END) AS lowest_expense_type
FROM ranked
GROUP BY city;
-- For each city, identifies which expense category has the highest total spend and which has the lowest.

---------------------------------------------------------------------------------
-- 6️⃣ Percentage Contribution of Female Spends by Expense Type
---------------------------------------------------------------------------------
SELECT 
    exp_type,
    SUM(CASE WHEN gender = 'F' THEN amount ELSE 0 END) * 100.0 / SUM(amount) AS female_spend_percentage
FROM mytable
GROUP BY exp_type
ORDER BY female_spend_percentage DESC;
-- Calculates what percentage of spending in each expense type is done by females.

---------------------------------------------------------------------------------
-- 7️⃣ Card & Expense Type Combo with Highest MoM Growth in Jan 2014
---------------------------------------------------------------------------------
WITH monthly_cte AS (
    SELECT 
        card_type,
        exp_type,
        DATEPART(YEAR, transaction_date) AS yr,
        DATEPART(MONTH, transaction_date) AS mn,
        SUM(amount) AS total_spend
    FROM mytable
    GROUP BY card_type, exp_type, DATEPART(YEAR, transaction_date), DATEPART(MONTH, transaction_date)
),
growth AS (
    SELECT *,
           LAG(total_spend) OVER (PARTITION BY card_type, exp_type ORDER BY yr, mn) AS prev_month_spend
    FROM monthly_cte
)
SELECT TOP 1
    card_type,
    exp_type,
    yr,
    mn,
    total_spend,
    prev_month_spend,
    (total_spend - prev_month_spend) AS mom_growth
FROM growth
WHERE prev_month_spend IS NOT NULL
  AND yr = 2014 AND mn = 1
ORDER BY mom_growth DESC;
-- This captures month-over-month growth for Jan 2014 and finds the card + expense type pair with highest growth.

---------------------------------------------------------------------------------
-- 8️⃣ Weekend Spend-to-Transaction Ratio by City
---------------------------------------------------------------------------------
SELECT TOP 1
    city,
    SUM(amount) * 1.0 / COUNT(*) AS avg_spend_per_txn
FROM mytable
WHERE DATEPART(WEEKDAY, transaction_date) IN (1, 7) -- Sunday = 1, Saturday = 7 (SQL Server convention)
GROUP BY city
ORDER BY avg_spend_per_txn DESC;
-- Finds which city has the highest average transaction size on weekends.

---------------------------------------------------------------------------------
-- 9️⃣ City That Reached 500th Transaction in Least Days
---------------------------------------------------------------------------------
WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY transaction_date, transaction_id) AS rn
    FROM mytable
)
SELECT TOP 1
    city,
    DATEDIFF(DAY, MIN(transaction_date), MAX(transaction_date)) AS days_to_500
FROM cte
WHERE rn IN (1, 500)
GROUP BY city
HAVING COUNT(*) = 2
ORDER BY days_to_500 ASC;
-- Computes how many days it took each city to reach its 500th transaction since the first one.


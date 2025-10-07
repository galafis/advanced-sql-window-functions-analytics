-- ================================================
-- COHORT ANALYSIS FOR CUSTOMER RETENTION
-- Author: Gabriel Demetrios Lafis
-- Description: Analyzing customer retention using cohort analysis
-- ================================================

-- Step 1: Identify the first purchase date for each customer (cohort)

WITH customer_cohorts AS (
    SELECT 
        "Customer ID",
        "Customer Name",
        MIN(DATE("Order Date")) as cohort_date,
        strftime('%Y-%m', MIN(DATE("Order Date"))) as cohort_month
    FROM train
    GROUP BY "Customer ID", "Customer Name"
),

-- Step 2: Get all customer orders with their cohort information

customer_orders AS (
    SELECT 
        t."Customer ID",
        t."Customer Name",
        DATE(t."Order Date") as order_date,
        strftime('%Y-%m', DATE(t."Order Date")) as order_month,
        cc.cohort_month,
        t."Sales"
    FROM train t
    JOIN customer_cohorts cc ON t."Customer ID" = cc."Customer ID"
),

-- Step 3: Calculate the months since cohort for each order

cohort_data AS (
    SELECT 
        "Customer ID",
        cohort_month,
        order_month,
        (strftime('%Y', order_month) - strftime('%Y', cohort_month)) * 12 + 
        (strftime('%m', order_month) - strftime('%m', cohort_month)) as months_since_cohort,
        "Sales"
    FROM customer_orders
),

-- Step 4: Calculate retention metrics

cohort_size AS (
    SELECT 
        cohort_month,
        COUNT(DISTINCT "Customer ID") as cohort_customers
    FROM customer_cohorts
    GROUP BY cohort_month
),

retention_table AS (
    SELECT 
        cd.cohort_month,
        cd.months_since_cohort,
        COUNT(DISTINCT cd."Customer ID") as active_customers,
        SUM(cd."Sales") as cohort_revenue
    FROM cohort_data cd
    GROUP BY cd.cohort_month, cd.months_since_cohort
)

-- Step 5: Final retention analysis with percentages

SELECT 
    rt.cohort_month,
    rt.months_since_cohort,
    cs.cohort_customers as initial_customers,
    rt.active_customers,
    ROUND(rt.active_customers * 100.0 / cs.cohort_customers, 2) as retention_rate,
    ROUND(rt.cohort_revenue, 2) as revenue
FROM retention_table rt
JOIN cohort_size cs ON rt.cohort_month = cs.cohort_month
WHERE rt.months_since_cohort <= 12
ORDER BY rt.cohort_month, rt.months_since_cohort;

-- SIMPLIFIED VERSION: Monthly retention overview

WITH first_purchase AS (
    SELECT 
        "Customer ID",
        strftime('%Y-%m', MIN("Order Date")) as cohort_month
    FROM train
    GROUP BY "Customer ID"
),
purchase_activity AS (
    SELECT 
        fp.cohort_month,
        strftime('%Y-%m', t."Order Date") as activity_month,
        COUNT(DISTINCT t."Customer ID") as active_customers
    FROM train t
    JOIN first_purchase fp ON t."Customer ID" = fp."Customer ID"
    GROUP BY fp.cohort_month, activity_month
)
SELECT 
    cohort_month,
    activity_month,
    active_customers
FROM purchase_activity
ORDER BY cohort_month, activity_month
LIMIT 50;

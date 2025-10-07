-- ================================================
-- LAG AND LEAD WINDOW FUNCTIONS
-- Author: Gabriel Demetrios Lafis
-- Description: Examples of LAG and LEAD for time series analysis
-- ================================================

-- LAG: Access data from previous rows
-- Use case: Calculating month-over-month growth

WITH monthly_sales AS (
    SELECT 
        strftime('%Y-%m', "Order Date") as month,
        SUM("Sales") as total_sales
    FROM train
    GROUP BY month
    ORDER BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY month) as previous_month_sales,
    total_sales - LAG(total_sales, 1) OVER (ORDER BY month) as sales_change,
    ROUND(
        (total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) * 100.0 / 
        LAG(total_sales, 1) OVER (ORDER BY month), 
        2
    ) as pct_change
FROM monthly_sales;

-- LEAD: Access data from following rows
-- Use case: Forecasting and comparing with future values

WITH monthly_sales AS (
    SELECT 
        strftime('%Y-%m', "Order Date") as month,
        SUM("Sales") as total_sales
    FROM train
    GROUP BY month
    ORDER BY month
)
SELECT 
    month,
    total_sales,
    LEAD(total_sales, 1) OVER (ORDER BY month) as next_month_sales,
    LEAD(total_sales, 1) OVER (ORDER BY month) - total_sales as future_change
FROM monthly_sales;

-- PRACTICAL EXAMPLE: Customer purchase patterns
-- Analyzing time between purchases

WITH customer_orders AS (
    SELECT 
        "Customer ID",
        "Customer Name",
        "Order Date",
        "Sales",
        LAG("Order Date", 1) OVER (PARTITION BY "Customer ID" ORDER BY "Order Date") as previous_order_date
    FROM train
)
SELECT 
    "Customer ID",
    "Customer Name",
    "Order Date",
    previous_order_date,
    julianday("Order Date") - julianday(previous_order_date) as days_since_last_order,
    "Sales"
FROM customer_orders
WHERE previous_order_date IS NOT NULL
ORDER BY "Customer ID", "Order Date"
LIMIT 50;

-- ADVANCED EXAMPLE: Running comparison with multiple periods

WITH daily_sales AS (
    SELECT 
        DATE("Order Date") as order_date,
        SUM("Sales") as daily_total
    FROM train
    GROUP BY order_date
    ORDER BY order_date
)
SELECT 
    order_date,
    daily_total,
    LAG(daily_total, 1) OVER (ORDER BY order_date) as prev_day,
    LAG(daily_total, 7) OVER (ORDER BY order_date) as same_day_last_week,
    LAG(daily_total, 30) OVER (ORDER BY order_date) as same_day_last_month
FROM daily_sales
ORDER BY order_date DESC
LIMIT 30;

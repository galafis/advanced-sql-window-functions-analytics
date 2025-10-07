-- ================================================
-- RECURSIVE COMMON TABLE EXPRESSIONS (CTEs)
-- Author: Gabriel Demetrios Lafis
-- Description: Examples of recursive CTEs for hierarchical and sequential data
-- ================================================

-- EXAMPLE 1: Generate a date series
-- Use case: Creating a calendar table for time series analysis

WITH RECURSIVE date_series AS (
    -- Base case: start date
    SELECT DATE('2014-01-01') as date
    
    UNION ALL
    
    -- Recursive case: add one day
    SELECT DATE(date, '+1 day')
    FROM date_series
    WHERE date < DATE('2018-12-31')
)
SELECT 
    date,
    strftime('%Y', date) as year,
    strftime('%m', date) as month,
    strftime('%d', date) as day,
    strftime('%w', date) as day_of_week,
    CASE strftime('%w', date)
        WHEN '0' THEN 'Sunday'
        WHEN '1' THEN 'Monday'
        WHEN '2' THEN 'Tuesday'
        WHEN '3' THEN 'Wednesday'
        WHEN '4' THEN 'Thursday'
        WHEN '5' THEN 'Friday'
        WHEN '6' THEN 'Saturday'
    END as day_name
FROM date_series
LIMIT 100;

-- EXAMPLE 2: Number sequence generation
-- Use case: Creating test data or generating sequences

WITH RECURSIVE number_sequence AS (
    SELECT 1 as n
    
    UNION ALL
    
    SELECT n + 1
    FROM number_sequence
    WHERE n < 100
)
SELECT 
    n,
    n * n as square,
    n * n * n as cube
FROM number_sequence;

-- EXAMPLE 3: Fibonacci sequence
-- Use case: Mathematical computations and pattern analysis

WITH RECURSIVE fibonacci AS (
    SELECT 
        0 as n,
        0 as fib_n,
        1 as fib_n_plus_1
    
    UNION ALL
    
    SELECT 
        n + 1,
        fib_n_plus_1,
        fib_n + fib_n_plus_1
    FROM fibonacci
    WHERE n < 20
)
SELECT 
    n,
    fib_n as fibonacci_number
FROM fibonacci;

-- PRACTICAL EXAMPLE: Fill gaps in time series data
-- Use case: Ensuring complete date ranges for analysis

WITH RECURSIVE all_dates AS (
    SELECT MIN(DATE("Order Date")) as date FROM train
    
    UNION ALL
    
    SELECT DATE(date, '+1 day')
    FROM all_dates
    WHERE date < (SELECT MAX(DATE("Order Date")) FROM train)
),
daily_sales AS (
    SELECT 
        DATE("Order Date") as date,
        SUM("Sales") as total_sales
    FROM train
    GROUP BY DATE("Order Date")
)
SELECT 
    ad.date,
    COALESCE(ds.total_sales, 0) as total_sales,
    CASE WHEN ds.total_sales IS NULL THEN 'No Sales' ELSE 'Has Sales' END as status
FROM all_dates ad
LEFT JOIN daily_sales ds ON ad.date = ds.date
ORDER BY ad.date
LIMIT 100;

-- ================================================
-- RANKING WINDOW FUNCTIONS
-- Author: Gabriel Demetrios Lafis
-- Description: Examples of ROW_NUMBER, RANK, DENSE_RANK, and NTILE
-- ================================================

-- ROW_NUMBER: Assigns a unique sequential integer to rows within a partition
-- Use case: Identifying the top N items per category

SELECT 
    "Customer Name",
    "Category",
    "Sales",
    ROW_NUMBER() OVER (PARTITION BY "Category" ORDER BY "Sales" DESC) as row_num
FROM train
WHERE "Category" IN ('Furniture', 'Office Supplies', 'Technology')
ORDER BY "Category", row_num
LIMIT 30;

-- RANK: Assigns a rank with gaps for ties
-- Use case: Finding products with the highest sales (ties get same rank)

SELECT 
    "Product Name",
    "Category",
    "Sales",
    RANK() OVER (PARTITION BY "Category" ORDER BY "Sales" DESC) as sales_rank
FROM train
WHERE "Category" IN ('Furniture', 'Office Supplies', 'Technology')
ORDER BY "Category", sales_rank
LIMIT 30;

-- DENSE_RANK: Assigns a rank without gaps for ties
-- Use case: Creating compact rankings where ties don't create gaps

SELECT 
    "Product Name",
    "Category",
    "Sales",
    DENSE_RANK() OVER (PARTITION BY "Category" ORDER BY "Sales" DESC) as dense_sales_rank
FROM train
WHERE "Category" IN ('Furniture', 'Office Supplies', 'Technology')
ORDER BY "Category", dense_sales_rank
LIMIT 30;

-- NTILE: Distributes rows into a specified number of groups
-- Use case: Segmenting customers into quartiles for analysis

SELECT 
    "Customer Name",
    "Sales",
    NTILE(4) OVER (ORDER BY "Sales" DESC) as sales_quartile
FROM (
    SELECT 
        "Customer Name",
        SUM("Sales") as "Sales"
    FROM train
    GROUP BY "Customer Name"
) customer_totals
ORDER BY sales_quartile, "Sales" DESC
LIMIT 40;

-- PRACTICAL EXAMPLE: Finding the top 3 products per category

WITH ranked_products AS (
    SELECT 
        "Category",
        "Product Name",
        SUM("Sales") as total_sales,
        ROW_NUMBER() OVER (PARTITION BY "Category" ORDER BY SUM("Sales") DESC) as rn
    FROM train
    GROUP BY "Category", "Product Name"
)
SELECT 
    "Category",
    "Product Name",
    total_sales
FROM ranked_products
WHERE rn <= 3
ORDER BY "Category", rn;

"""
SQL Query Testing Framework
Author: Gabriel Demetrios Lafis
Description: Tests to validate SQL queries functionality
"""

import sqlite3
import pandas as pd
import os
import sys

def setup_database():
    """Create an in-memory SQLite database and load the dataset"""
    conn = sqlite3.connect(':memory:')
    
    # Load the dataset
    data_path = os.path.join(os.path.dirname(__file__), '..', 'data', 'train.csv')
    df = pd.read_csv(data_path, encoding='latin-1')
    
    # Load into SQLite
    df.to_sql('train', conn, index=False, if_exists='replace')
    
    return conn

def test_ranking_functions():
    """Test ranking window functions"""
    conn = setup_database()
    
    # Test ROW_NUMBER
    query = '''
    SELECT 
        "Customer Name",
        "Category",
        "Sales",
        ROW_NUMBER() OVER (PARTITION BY "Category" ORDER BY "Sales" DESC) as row_num
    FROM train
    WHERE "Category" IN ('Furniture', 'Office Supplies', 'Technology')
    LIMIT 10
    '''
    
    result = pd.read_sql_query(query, conn)
    
    assert len(result) > 0, "Query returned no results"
    assert 'row_num' in result.columns, "row_num column not found"
    
    print("✓ Ranking functions test passed")
    conn.close()

def test_lag_lead_functions():
    """Test LAG and LEAD functions"""
    conn = setup_database()
    
    query = '''
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
        LAG(total_sales, 1) OVER (ORDER BY month) as previous_month_sales
    FROM monthly_sales
    LIMIT 10
    '''
    
    result = pd.read_sql_query(query, conn)
    
    assert len(result) > 0, "Query returned no results"
    assert 'previous_month_sales' in result.columns, "previous_month_sales column not found"
    
    print("✓ LAG/LEAD functions test passed")
    conn.close()

def test_recursive_cte():
    """Test recursive CTEs"""
    conn = setup_database()
    
    query = '''
    WITH RECURSIVE number_sequence AS (
        SELECT 1 as n
        UNION ALL
        SELECT n + 1
        FROM number_sequence
        WHERE n < 10
    )
    SELECT n FROM number_sequence
    '''
    
    result = pd.read_sql_query(query, conn)
    
    assert len(result) == 10, f"Expected 10 rows, got {len(result)}"
    assert result['n'].tolist() == list(range(1, 11)), "Sequence is incorrect"
    
    print("✓ Recursive CTE test passed")
    conn.close()

def test_cohort_analysis():
    """Test cohort analysis query"""
    conn = setup_database()
    
    query = '''
    WITH first_purchase AS (
        SELECT 
            "Customer ID",
            strftime('%Y-%m', MIN("Order Date")) as cohort_month
        FROM train
        GROUP BY "Customer ID"
    )
    SELECT 
        cohort_month,
        COUNT(DISTINCT "Customer ID") as customer_count
    FROM first_purchase
    GROUP BY cohort_month
    LIMIT 10
    '''
    
    result = pd.read_sql_query(query, conn)
    
    assert len(result) > 0, "Query returned no results"
    assert 'customer_count' in result.columns, "customer_count column not found"
    
    print("✓ Cohort analysis test passed")
    conn.close()

def run_all_tests():
    """Run all tests"""
    print("Running SQL Query Tests...")
    print("=" * 50)
    
    try:
        test_ranking_functions()
        test_lag_lead_functions()
        test_recursive_cte()
        test_cohort_analysis()
        
        print("=" * 50)
        print("✓ All tests passed successfully!")
        return 0
    except Exception as e:
        print(f"\n✗ Test failed with error: {str(e)}")
        return 1

if __name__ == "__main__":
    sys.exit(run_all_tests())

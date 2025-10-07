# Advanced SQL Analytics Toolkit

![SQL](https://img.shields.io/badge/SQL-025E8C?style=for-the-badge&logo=sql&logoColor=white) ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white) ![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)

---

## 🇧🇷 Análise Avançada com SQL

Este repositório é um toolkit abrangente para realizar análises de dados avançadas utilizando SQL. O foco principal é demonstrar o poder das **Window Functions**, **Common Table Expressions (CTEs)** e técnicas de **otimização de queries** para resolver problemas complexos de negócio.

### 🎯 Objetivo

O objetivo deste projeto é fornecer um guia prático e funcional para analistas e cientistas de dados que desejam aprofundar seus conhecimentos em SQL, indo além das consultas básicas. As técnicas aqui apresentadas são essenciais para a manipulação de grandes volumes de dados e para a extração de insights valiosos em cenários do mundo real.

### 📂 Conteúdo do Repositório

*   **/sql**: Contém scripts SQL com exemplos práticos, divididos por categoria:
    *   `window_functions`: Exemplos de `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`, `LAG`, etc.
    *   `cte_examples`: Uso de CTEs, incluindo exemplos recursivos.
    *   `optimization`: Técnicas para otimização de performance em queries.
    *   `time_series`: Análise de séries temporais com SQL.
    *   `cohort_analysis`: Scripts para análise de cohort e retenção de clientes.
*   **/data**: Dataset utilizado nos exemplos (Superstore Sales).
*   **/docs**: Documentação adicional sobre os conceitos abordados.
*   **/tests**: Testes para garantir a qualidade e funcionalidade dos scripts SQL.

### 📊 Dataset

Utilizamos o dataset [Superstore Sales](https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting), que contém dados de vendas de uma superloja global por 4 anos. É um dataset rico para a prática de análise de dados e extração de insights de negócio.

### 🚀 Como Usar

```bash
# Clone o repositório
git clone https://github.com/galafis/advanced-sql-window-functions-analytics.git

# Navegue até o diretório
cd advanced-sql-window-functions-analytics

# Execute os testes
python3 tests/test_sql_queries.py
```

### 📝 Exemplos de Queries

**Ranking de Produtos por Categoria:**
```sql
SELECT 
    "Product Name",
    "Category",
    "Sales",
    RANK() OVER (PARTITION BY "Category" ORDER BY "Sales" DESC) as sales_rank
FROM train
WHERE "Category" IN ('Furniture', 'Office Supplies', 'Technology')
ORDER BY "Category", sales_rank
LIMIT 10;
```

**Análise de Crescimento Mensal:**
```sql
WITH monthly_sales AS (
    SELECT 
        strftime('%Y-%m', "Order Date") as month,
        SUM("Sales") as total_sales
    FROM train
    GROUP BY month
)
SELECT 
    month,
    total_sales,
    LAG(total_sales, 1) OVER (ORDER BY month) as previous_month,
    ROUND((total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) * 100.0 / 
          LAG(total_sales, 1) OVER (ORDER BY month), 2) as growth_pct
FROM monthly_sales;
```

### ✅ Testes

O repositório inclui testes automatizados para garantir a funcionalidade de todas as queries. Execute `python3 tests/test_sql_queries.py` para validar.

---

### 📊 Dataset

We use the [Superstore Sales](https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting) dataset, which contains sales data from a global superstore over 4 years. It is a rich dataset for practicing data analysis and extracting business insights.

---

## 🇬🇧 Advanced SQL Analytics Toolkit

This repository is a comprehensive toolkit for performing advanced data analysis using SQL. The main focus is to demonstrate the power of **Window Functions**, **Common Table Expressions (CTEs)**, and **query optimization** techniques to solve complex business problems.

### 🎯 Objective

The goal of this project is to provide a practical and functional guide for data analysts and scientists who want to deepen their SQL knowledge beyond basic queries. The techniques presented here are essential for handling large volumes of data and extracting valuable insights in real-world scenarios.

### 📂 Repository Content

*   **/sql**: Contains SQL scripts with practical examples, divided by category:
    *   `window_functions`: Examples of `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`, `LAG`, etc.
    *   `cte_examples`: Use of CTEs, including recursive examples.
    *   `optimization`: Techniques for query performance optimization.
    *   `time_series`: Time series analysis with SQL.
    *   `cohort_analysis`: Scripts for cohort analysis and customer retention.
*   **/data**: Dataset used in the examples (Superstore Sales).
*   **/docs**: Additional documentation on the concepts covered.
*   **/tests**: Tests to ensure the quality and functionality of the SQL scripts.

### 📊 Dataset

We use the [Superstore Sales](https://www.kaggle.com/datasets/rohitsahoo/sales-forecasting) dataset, which contains sales data from a global superstore over 4 years. It is a rich dataset for practicing data analysis and extracting business insights.


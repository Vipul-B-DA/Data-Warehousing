/*
================================================================================
CUSTOMER REPORT
================================================================================
Purpose:
    - This report consolidates key customer metrics and behaviours.

Highlights:
    1. Gathers essential fields such as names, ages and transactional details.
    2. Segment customers into categories (VIP, Regular, New) and Age groups.
    3. Aggregates customer level metrices:
        - total order
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spends

================================================================================
*/

--------------------------------------------------------------------------------
-- >> BASE QUERY: Retrieves core columns from tables
--------------------------------------------------------------------------------
IF OBJECT_ID('gold.report_customers', 'V') IS NOT NULL
    DROP VIEW gold.report_customers;
GO

CREATE VIEW gold.report_customers AS


    WITH base_query AS
    (
        SELECT
            f.order_number,
            f.product_key,
            f.order_date,
            f.sales_amount,
            f.quantity,
            c.customer_key,
            c.customer_number,
            CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
            DATEDIFF(YEAR,birthdate,GETDATE()) AS Age
        FROM gold.fact_sales f
        LEFT JOIN gold.dim_customers c
        ON f.customer_key = c.customer_key
        WHERE order_date IS NOT NULL
    ),

    --------------------------------------------------------------------------------
    -- >> CUSTOMER AGGREGATIONS: Summarises key metrics at customer level
    --------------------------------------------------------------------------------
    customer_aggregation AS
    (
        SELECT
            customer_key,
            customer_number,
            customer_name,
            Age,
            COUNT(DISTINCT order_number) AS Total_orders,
            SUM(sales_amount) AS Total_sales, 
            SUM(quantity) AS Total_quantity,
            COUNT(DISTINCT product_key) AS Total_products,
            MAX(order_date) AS last_order_date,
            DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
        FROM base_query
        GROUP BY 
            customer_key,
            customer_number,
            customer_name,
            Age
    )

    SELECT
            customer_key,
            customer_number,
            customer_name,
            Age,
            CASE WHEN Age < 20 THEN 'Under 20'
                WHEN Age BETWEEN 20 AND 29 THEN '20 to 29'
                WHEN Age BETWEEN 30 AND 39 THEN '30 to 39'
                WHEN Age BETWEEN 40 AND 49 THEN '40 to 49'
                WHEN Age BETWEEN 50 AND 59 THEN '50 to 59'
                ELSE '50 Above'
            END AS Age_Group,
            CASE WHEN lifespan >= 12 AND Total_sales > 5000 THEN 'VIP'
                WHEN lifespan >= 12 AND Total_sales <= 5000 THEN 'Regular'
                ELSE 'New'
            END AS customer_segment,
            last_order_date,
            DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency, 
            Total_orders,
            Total_sales, 
            Total_quantity,
            Total_products,
            lifespan,
            -- Compute average order value
            CASE WHEN Total_orders = 0 THEN 0
                ELSE Total_sales/Total_orders 
            END AS Avg_order_value,
            -- Compute average monthly spend
            CASE WHEN lifespan = 0 THEN Total_sales
                ELSE Total_sales/lifespan
            END AS avg_monthly_spend
        FROM customer_aggregation

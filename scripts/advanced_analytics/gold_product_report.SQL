/*
================================================================================
PRODUCT REPORT
================================================================================
Purpose:
    - This report consolidates key product metrics and behaviours.

Highlights:
    1. Gathers essential fields such as product names, category, subcategory and cost.
    2. Segment products by revenue to identify High-performers, Mid-range or Low-range.
    3. Aggregates product level metrices:
        - total order
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order revenue
        - average monthly revenue

================================================================================
*/

--------------------------------------------------------------------------------
-- >> BASE QUERY: Retrieves core columns from tables
--------------------------------------------------------------------------------
IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO


CREATE VIEW gold.report_products AS

    WITH base_query AS
    (
        SELECT
            f.order_number,
            f.order_date,
            f.sales_amount,
            f.quantity,
            p.product_key,
            p.product_name,
            p.category,
            p.sub_category,
            p.cost
        FROM gold.fact_sales f
        LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
        WHERE order_date IS NOT NULL
    )

    --------------------------------------------------------------------------------
    -- >> CUSTOMER AGGREGATIONS: Summarises key metrics at customer level
    --------------------------------------------------------------------------------
    , product_aggregation AS
    (
        SELECT
            product_key,
            product_name,
            category,
            sub_category,
            cost,
            COUNT(DISTINCT order_number) AS Total_orders,
            SUM(sales_amount) AS Total_sales, 
            SUM(quantity) AS Total_quantity,
            MAX(order_date) AS last_sale_date,
            DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
            ROUND(AVG(CAST(sales_amount AS float)/ NULLIF (quantity,0)),1) AS Avg_selling_price
        FROM base_query
        GROUP BY 
            product_key,
            product_name,
            category,
            sub_category,
            cost
    )

    SELECT
            product_key,
            product_name,
            category,
            sub_category,
            cost,
            last_sale_date,
            DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,
            CASE WHEN Total_sales > 50000 THEN 'High-Performer'
                 WHEN Total_sales >= 10000 THEN 'Mid-performer'
                 ELSE 'Low-performer'
            END AS product_segment,     
            Total_orders,
            Total_sales, 
            Total_quantity,
            lifespan,
            Avg_selling_price,

            -- Compute average order revenue
            CASE WHEN Total_orders = 0 THEN 0
                 ELSE Total_sales/Total_orders 
            END AS Avg_order_revenue,
            -- Compute average monthly revenue
            CASE WHEN lifespan = 0 THEN Total_sales
                ELSE Total_sales/lifespan
            END AS avg_monthly_spend
        FROM product_aggregation

/*
=======================================================
ADVANCED DATA ANALYTICS PROJECT
=======================================================
*/


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- >> TYPE1: CHANGE OVER TIME TRENDS

-- Analyse change of sales over years
  SELECT
  YEAR(order_date),
  SUM(sales_amount)
  FROM gold.fact_sales
  GROUP BY YEAR(order_date)
  ORDER BY YEAR(order_date) 

-- Change of metrics over months
  SELECT
  MONTH(order_date),
  SUM(sales_amount) AS Total_sales,
  SUM(quantity) AS Total_Qty,
  COUNT(DISTINCT customer_key) AS Total_customers
  FROM gold.fact_sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY MONTH(order_date)
  ORDER by MONTH(order_date)


-- Change of metrics over months for each year
  SELECT
  YEAR(order_date),
  MONTH(order_date),
  SUM(sales_amount) AS Total_sales,
  SUM(quantity) AS Total_Qty,
  COUNT(DISTINCT customer_key) AS Total_customers
  FROM gold.fact_sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY YEAR(order_date), MONTH(order_date)
  ORDER by YEAR(order_date), MONTH(order_date)


-- Change of metrics over months for each year Using DATETRUNC for displaying in a single column
  SELECT
  DATETRUNC(MONTH, order_date),
  SUM(sales_amount) AS Total_sales,
  SUM(quantity) AS Total_Qty,
  COUNT(DISTINCT customer_key) AS Total_customers
  FROM gold.fact_sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY DATETRUNC(MONTH, order_date)
  ORDER by DATETRUNC(MONTH, order_date)


-- Change of metrics over months for each year showing Month name abbreviation 
  SELECT
  FORMAT(order_date, 'yyyy-MMM'),
  SUM(sales_amount) AS Total_sales,
  SUM(quantity) AS Total_Qty,
  COUNT(DISTINCT customer_key) AS Total_customers
  FROM gold.fact_sales
  WHERE MONTH(order_date) IS NOT NULL
  GROUP BY FORMAT(order_date, 'yyyy-MMM')
  ORDER by FORMAT(order_date, 'yyyy-MMM')


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- >> TYPE2: CUMULATIVE ANALYSIS

-- Calculate the total sales per month
-- and the running total of sales over time
  SELECT
  order_date,
  Total_sales,
  SUM(Total_sales) OVER(PARTITION BY YEAR(order_date) ORDER BY order_date) AS Running_total_sales
  FROM
  (
      SELECT
      DATETRUNC(MONTH,order_date) AS order_date,
      SUM(sales_amount) AS Total_sales
      FROM gold.fact_sales
      WHERE order_date IS NOT NULL
      GROUP BY DATETRUNC(MONTH,order_date)
      ) t


-- Calculate the total sales and average price per year
-- and the running avg price per year
  SELECT 
  order_date,
  Total_sales,
  SUM(Total_sales) OVER (ORDER BY order_date) AS Running_total_sales,
  Avg_price,
  AVG(Avg_price) OVER (ORDER BY order_date) AS Running_price
  FROM(  
      SELECT
      DATETRUNC(YEAR,order_date) AS order_date,
      SUM(sales_amount) AS Total_sales,
      AVG(price) AS Avg_price
      FROM gold.fact_sales
      WHERE order_date IS NOT NULL
      GROUP BY DATETRUNC(YEAR,order_date)
  )t 


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- >> TYPE3: PERFROMANCE ANALYSIS (with a target measure)

-- Analyse the yearly performance of the products by comparing their sales to
-- both the average sales performance of the product and the previous year sales
  WITH yearly_product_sales AS
  (
      SELECT
          YEAR(f.order_date) AS order_year,
          p.product_name,
          SUM(f.sales_amount) AS Total_sales
      FROM gold.fact_sales f 
      LEFT JOIN gold.dim_products p 
      ON f.product_key = p.product_key
      WHERE order_date IS NOT NULL
      GROUP BY 
      YEAR(f.order_date), 
      p.product_name
  )
  
  SELECT
      order_year,
      product_name,
      Total_sales,
      AVG(Total_sales) OVER (PARTITION BY product_name) AS avg_sales,
      Total_sales - AVG(Total_sales) OVER (PARTITION BY product_name) AS Diff_avg,
      CASE WHEN Total_sales - AVG(Total_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
          WHEN Total_sales - AVG(Total_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
          ELSE 'Avg'
      END AS Avg_change,
  
      LAG(Total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS PrevYear_sales,
      Total_sales - LAG(Total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS Diff_PrevYear,
      CASE WHEN Total_sales - LAG(Total_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
          WHEN Total_sales - LAG(Total_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
          ELSE 'No change'
      END AS YoY_Change_sales
  
  FROM yearly_product_sales


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- >> TYPE4: PART TO WHOLE ANALYSIS

-- Which categories contribute most to overall sales
  WITH category_sales AS
  (
      SELECT 
      p.category,
      SUM(f.sales_amount) AS Total_sales
      FROM gold.fact_sales f 
      LEFT JOIN gold.dim_products p 
      ON p.product_key = f.product_key
      GROUP BY p.category
  )
  
  SELECT
  category,
  Total_sales,
  SUM(Total_sales) OVER() AS Overall_Sales,
  ROUND((CAST(Total_sales AS float)/SUM(Total_sales) OVER())*100, 2) AS Percent_total
  FROM category_sales
  ORDER BY Total_sales DESC


--------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------

-- >> TYPE5: DATA SEGMENTATION

-- Segment products into cost ranges and count
-- hoow many products fall into each segment
  WITH product_segments AS
  (
      SELECT
      product_key,
      product_name,
      cost,
      CASE WHEN cost< 100 THEN 'Below 100'
          WHEN cost BETWEEN 100 AND 500 THEN '100 to 500'
          WHEN cost BETWEEN 500 AND 1000 THEN '500 to 1000'
          ELSE 'Above 1000'
      END AS cost_range 
      FROM gold.dim_products
  )
  
  SELECT
      cost_range,
      COUNT(product_key) AS Total_products
      FROM product_segments
      GROUP BY cost_range
      ORDER BY Total_products DESC


/* Group customers into three segments based on their spending behaviour :
    - VIP: Customers with atleast 12 months of history and spending more than 5,000
    - Regular: Customers with atleast 12 months of history but spending 5,000 or less
    - New: Customer with less than 12 months history
And find the total number of customers by each group
*/
  WITH customer_spendings AS
  (
      SELECT
      c.customer_key,
      SUM(f.sales_amount) AS Total_spendings,
      MIN(order_date) AS first_order,
      MAX(order_date) AS last_order,
      DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
      FROM gold.fact_sales f 
      LEFT JOIN gold.dim_customers c 
      ON f.customer_key = c.customer_key
      GROUP BY c.customer_key
  )
  
  SELECT
  customer_segment,
  COUNT(customer_key) AS Total_customers
  FROM(
      SELECT
      customer_key,
      CASE WHEN lifespan >= 12 AND Total_spendings > 5000 THEN 'VIP'
          WHEN lifespan >= 12 AND Total_spendings <= 5000 THEN 'Regular'
          ELSE 'New'
      END AS customer_segment
      FROM customer_spendings
      )t 
  GROUP BY customer_segment



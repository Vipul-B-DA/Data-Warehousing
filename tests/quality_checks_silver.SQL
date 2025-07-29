/* 
===================================================================================
QUALITY CHECKS
===================================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy and
    standardisation across the 'Silver' schema. It includes checks for:
    - Null or Duplicate Primary Key.
    - Unwanted Spaces in String Fields.
    - Data Standardisation and Consistency.
    - Invalid Date Ranges and Orders.
    - Data consistency and integrity between related filds of other tables.

Usage Notes:
    - Run these checks after loading data into Silver layer.
    - Investigate and resolve any discrepancies found during the checks.

===================================================================================
*/

-- >> FOR TABLE 'crm_cust_info'

-- "QUALITY CHECK NO.1"
-- Check for Nulls or Duplicates in Primary key
-- Expectation: No Result
  SELECT
  cst_id,
  COUNT(*)
  FROM bronze.crm_cust_info
  GROUP BY cst_id
  HAVING COUNT(*) > 1 OR cst_id IS NULL

-- Ranking the records with same customer id based on their Create Date
-- Selecting the latest record and discarding the other duplicates
  SELECT
  *
  FROM (
      SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
          FROM bronze.crm_cust_info
          WHERE cst_id IS NOT NULL 
      )t 
  WHERE flag_latest = 1


-- "QUALITY CHECK NO.2"
-- Check for unwanted spaces
-- Expectation: No Result
  SELECT
  cst_firstname
  FROM bronze.crm_cust_info
  WHERE   cst_firstname != TRIM(cst_firstname);
  GO
  
  SELECT
  cst_lastname
  FROM bronze.crm_cust_info
  WHERE cst_lastname != TRIM(cst_lastname);
  GO

-- Removing Unwanted spaces from First and Last names and integrating with Quality Check no.1
  SELECT
  cst_id,
  cst_key,
  TRIM(cst_firstname) AS cst_firstname,
  TRIM(cst_lastname) AS cst_lastname,
  cst_marital_status,
  cst_gndr,
  cst_create_date
  FROM (
      SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
          FROM bronze.crm_cust_info
          WHERE cst_id IS NOT NULL 
      )t 
  WHERE flag_latest = 1


-- QUALITY Check No.3
-- Checking data consistency for Low cardinality columns
-- Stadardisation for Gender and Marital status fields
  SELECT DISTINCT cst_marital_status 
  FROM bronze.crm_cust_info;
  GO
  SELECT DISTINCT cst_gndr
  FROM bronze.crm_cust_info;
  GO

-- Ensuring Data Standardisation by maintaining a Normalised structure
  SELECT
  cst_id,
  cst_key,
  TRIM(cst_firstname) AS cst_firstname,
  TRIM(cst_lastname) AS cst_lastname,
  CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
       WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
       ELSE 'N/A'
  END cst_marital_status,
  CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
       WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
       ELSE 'N/A'
  END cst_gndr,
  cst_create_date
  FROM (
      SELECT
          *,
          ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag_latest
          FROM bronze.crm_cust_info
          WHERE cst_id IS NOT NULL 
      )t 
  WHERE flag_latest = 1


---------------------------------------------------------------------------------------------------------
-- >> FOR TABLE crm_prd_info

-- QUALTIY Check No.1
-- Checking for duplicates or NULLS
  SELECT
  prd_id,
  COUNT(*)
  FROM bronze.crm_prd_info
  GROUP BY prd_id
  HAVING COUNT(*) > 1 OR prd_id IS NULL
-- Obtained no result as per expectation


-- QUALITY Check No.2 
-- Unwanted spaces in Product name
  SELECT
  prd_nm
  FROM bronze.crm_prd_info
  WHERE prd_nm != TRIM(prd_nm)
-- Obtained no result as per expectation


-- QUALITY Check No.3
-- Check for NULLS or Negative Numbers in prd_cost
  SELECT prd_cost
  FROM bronze.crm_prd_info
  WHERE prd_cost < 0 or prd_cost IS NULL
-- Null Values obtained which can be replaced by 0 using COALESCE


-- QUALITY Check No.4
-- Data Consistency and Standardisation
-- Replacing prd_line info with full detail instead of abbreviations
  SELECT
  CASE UPPER(TRIM(prd_line))
      WHEN 'M' THEN 'Mountain'
      WHEN 'R' THEN 'Road'
      WHEN 'S' THEN 'Other Sales'
      WHEN 'T' THEN 'Touring'
  ELSE 'N//A'
  END AS prd_line
  FROM bronze.crm_prd_info


-- QUALITY Check No.5
-- Date Consistency of product start dates and end dates
-- The start dates cannot be newer than end dates and it should not overlap with costs of the same product
-- Also changing the data type from DATETIME to DATE as no info on time is provided

-- Using Window functions to derive end date using LEAD() on start date and getting an earlier date by subtracting 1
  SELECT
  prd_key,
  prd_nm,
  prd_start_dt,
  DATEADD (day,-1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
  FROM bronze.crm_prd_info


---------------------------------------------------------------------------------------------------------
-- >> FOR TABLE crm_sales_details

-- QUALITY Check No.1
-- Unwanted spaces in order number
  SELECT sls_ord_num FROM
  bronze.crm_sales_details 
  WHERE sls_ord_num != TRIM(sls_ord_num)
-- Obtained no result as per expectation

-- QUALITY Check No.2
-- Checking prd_key, cust_id mapping relationships with other table
  SELECT 
  sls_prd_key
  FROM bronze.crm_sales_details
  WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info);
  GO
  SELECT 
  sls_cust_id
  FROM bronze.crm_sales_details
  WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info);
  GO
-- Obtained no results, So data is consistent


-- QUALITY CHECK No.3
-- Checking for invalid dates
-- Looking for negative dates or having 0 and changing it to NULL
-- Converting the data type from INT to DATE
  SELECT 
  NULLIF (sls_order_dt, 0) sls_order_dt
  FROM bronze.crm_sales_details
  WHERE sls_order_dt <= 0
  OR LEN(sls_order_dt) != 8

-- SOLUTION: Removing Invalid dates to NULL and converting order date into DATE data type
  SELECT 
  CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
      ELSE CAST(CAST((sls_order_dt) AS VARCHAR) AS DATE)
  END AS sls_order_dt
  FROM bronze.crm_sales_details;
  GO
  SELECT 
  CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
      ELSE CAST(CAST((sls_ship_dt) AS VARCHAR) AS DATE)
  END AS sls_ship_dt
  FROM bronze.crm_sales_details;
  GO
  SELECT 
  CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
      ELSE CAST(CAST((sls_due_dt) AS VARCHAR) AS DATE)
  END AS sls_due_dt
  FROM bronze.crm_sales_details;


-- QUALITY CHECK No.4
-- Check Data Consistency between Sales, Quantity and Price
-- Sales = Quantity * Price
-- No negative values, NULLS or zeros
  SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
  FROM bronze.crm_sales_details
  WHERE sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL OR sls_price IS NULL OR sls_quantity IS NULL
  OR sls_sales <=0 OR sls_price <=0 OR sls_quantity <=0
  ORDER BY sls_sales, sls_quantity, sls_price

-- SOLUTIONS: NULL, Negative or ZERO Sales can be derived from (Price * Quantity)
-- SOLUTIONS: Negative Price can be converted to positive and NULL/Zero can be Derived from Sales, Qty
  SELECT
  CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
       THEN sls_quantity * ABS(sls_price)
  ELSE sls_sales
  END AS sls_sales,

  CASE WHEN sls_price IS NULL OR sls_price <= 0
       THEN sls_sales / NULLIF(sls_quantity,0)
  ELSE sls_price
  END AS sls_price
  FROM bronze.crm_sales_details
  ORDER BY sls_sales


---------------------------------------------------------------------------------------------------------
-- >> FOR TABLE erp_cust_az12

-- QUALITY Check No.1 
-- Checking the 'cid' key format and matching it with crm_table to create a relationship
-- 'cid' key in this table consists extra initial characters that needs to be removed for matching
-- with the cst_key of crm_sales_details table
  SELECT 
  CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
       ELSE cid
  END AS cid
  FROM bronze.erp_cust_az12


-- QUALITY Check No.2
-- Identifying invalidn or out of range dates
  SELECT DISTINCT
  bdate
  FROM bronze.erp_cust_az12
  WHERE bdate < '1920-01-01' OR bdate > GETDATE()

-- SOLUTION: Changing future bdates to NULL
  SELECT 
  CASE WHEN bdate > GETDATE() THEN NULL
      ELSE bdate
  END AS bdate
  FROM bronze.erp_cust_az12


-- QUALITY CHECK No.3
-- Data Consistencty and Standardisation check in Gender column
  SELECT DISTINCT
  gen
  FROM bronze.erp_cust_az12

-- SOLUTION
  SELECT DISTINCT
  gen,
  CASE WHEN SUBSTRING(UPPER(TRIM(gen)),1,1) = 'F' THEN 'Female'
       WHEN SUBSTRING(UPPER(TRIM(gen)),1,1) = 'M' THEN 'Male'
      ELSE 'N/A'
  END AS gen
  FROM bronze.erp_cust_az12



---------------------------------------------------------------------------------------------------------
-- >> FOR TABLE erp_loc_a101

-- QUALITY Check No.1
-- Bringing the cid into correct format for setting a relationship with other keys
  SELECT
  REPLACE (cid, '-', '') AS cid
  FROM bronze.erp_loc_a101
  WHERE REPLACE (cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info)
-- No outputs obtained after transformation


-- QUALITY Check No.2
-- Data Standardisation & Consistency for Country field
  SELECT DISTINCT 
  cntry,
  FROM bronze.erp_loc_a101

-- SOLUTION
  SELECT
  REPLACE (cid, '-', '') AS cid,
  CASE WHEN SUBSTRING(TRIM(cntry),1,2) = 'DE' THEN 'Germany'
       WHEN SUBSTRING(TRIM(cntry),1,2) IN ('US','Us') THEN 'United States'
       WHEN SUBSTRING(cntry,1,1) = '' OR cntry IS NULL THEN 'N/A'
       ELSE TRIM(cntry)
  END AS cntry
  FROM bronze.erp_loc_a101


---------------------------------------------------------------------------------------------------------
-- >> FOR TABLE erp_px_cat_g1v2

-- QUALITY Check No.1 
-- Checking unwanted spaces
  SELECT * FROM bronze.erp_px_cat_g1v2
  WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)
-- Obtained No results, data quality is good

-- QUALITY Check No.2
-- Data Standardisation and Consistency
  SELECT DISTINCT 
  cat,
  maintenance
  FROM bronze.erp_px_cat_g1v2
-- No inconsistency found, data can be inserted as it is

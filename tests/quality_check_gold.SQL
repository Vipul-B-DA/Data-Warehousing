/*
===============================================================================
QUALITY CHECKS
===============================================================================
Script Purpose: 
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the 'Gold' layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between Fact and Dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver layer.
    - Investigate and resolve any discrepancies found during checks.

===============================================================================
*/

-- >> QUALITY CEHCKS AND DATA INTEGRATION ON JOINED TABLES

--------------------------------------------------------------------------------------------
-- >> "CUSTOMER DIMENSION OBJECT"
-- QUALITY Check No.1
-- Checking for duplpicates in join
    SELECT
    cst_id,
    COUNT(*)
    FROM(
        SELECT 
            ci.cst_id,
            ci.cst_key,
            ci.cst_firstname,
            ci.cst_lastname,
            ci.cst_marital_status,
            ci.cst_gndr,
            ci.cst_create_date,
            ca.bdate,
            ca.gen,
            la.cntry
        FROM silver.crm_cust_info ci
    
        LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    
        LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
    )t 
    GROUP BY cst_id
    HAVING COUNT(*) > 1 ;

-- No results obtained, Data consistent


-- QUALITY Check No.2
-- Two fields of Gender are present in Join
-- We need to integrate both of their data into single column using appropriate values
    SELECT DISTINCT
        ci.cst_gndr,
        ca.gen
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

-- We are obtaining inconsistent data from the two fields
-- Treating crm source as our master source for gender info
-- SOLUTION
    SELECT DISTINCT
        ci.cst_gndr,
        ca.gen,
        CASE WHEN ci.cst_gndr != 'N/A'
             THEN ci.cst_gndr
             ELSE COALESCE(ca.gen, 'N/A')
        END AS new_gen
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
    ON ci.cst_key = ca.cid

--------------------------------------------------------------------------------------------

-- >> "PRODUCTS DIMENSION OBJECT"

-- QUALITY Check  No. 1
-- Filtering out all historical data
-- Keeping only the new relevant data for the same products
    SELECT 
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance 
    FROM silver.crm_prd_info pi
    LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pi.cat_id = pc.id
    WHERE prd_end_dt IS NULL -- Keeping the latest product record


-- QUALITY Check No.2
-- Checking for duplicates
    SELECT
    prd_id,
    COUNT(*)
    FROM (
        SELECT 
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        pc.cat,
        pc.subcat,
        pc.maintenance 
    FROM silver.crm_prd_info pi
    LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pi.cat_id = pc.id
    WHERE prd_end_dt IS NULL
    )t 
    GROUP BY prd_id
    HAVING COUNT(*) > 1 ;

-- No results obtained, data is consistent

--------------------------------------------------------------------------------------------
-- >> "Integrated Fact and Dimension Table Object"
-- For our integrated FACT and DIMENSION tables
-- Checking Foreign Key Integrity by joining
    SELECT *
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_customers c
    ON f.customer_key = c.customer_key
    WHERE c.customer_key IS NULL ;
    GO
    SELECT *
    FROM gold.fact_sales f 
    LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key
    WHERE p.product_key IS NULL ;

-- No output, so data is consistent after Joining Facts with Dimensions

/*
=========================================================================
DDL Scripts : Create Bronze Tables
=========================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing 
    tables if they already exists.
    Run this script to redefine the DDL structure of bronze tables.
=========================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO
  
CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(20),
    cst_firstname VARCHAR(20),
    cst_lastname VARCHAR(20),
    cst_marital_status VARCHAR(1),
    cst_gndr VARCHAR(1),
    cst_create_date DATE
);
GO
  
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(20),
    prd_start_dt DATE,
    prd_end_dt DATE
);
GO
  
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
GO
  
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen VARCHAR(15)
);
GO
  
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
    cid NVARCHAR(50),
    cntry VARCHAR(50),
);
GO
  
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
    id NVARCHAR(20),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance VARCHAR(10),
);

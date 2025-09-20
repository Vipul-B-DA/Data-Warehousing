# End-to-End Sales Analytics Pipeline: SQL Data Warehouse & Tableau Dashboards

## Project Overview

Welcome to the **Data Warehouse & BI Analytics Project** repository!
This project demonstrates a full-scale data solution, transforming raw, disconnected sales data from multiple sources into a **unified data warehouse**. This warehouse serves as a single source of truth for **driving strategic business decisions** through advanced **SQL analytics** and **interactive Tableau dashboards**. Designed as a portfolio project, it highlights industry best practices in data engineering and analytics.

The core of this project is a robust, automated data pipeline built entirely within **Microsoft SQL Server**, following a modern **Medallion Architecture** to ensure data integrity and scalability. This follows a full-scale **Data Analytics** and **Exploratory Data Analysis (EDA)** utilising MSSQL to scrape out business insights and transform our cleaned data into a more presentable, report-friendly format. It ends with creating two **interactive visualisations** of the refined data in the form of **Tableau Dashboards**.
 
---

## Business Objective

The primary goal was to consolidate disparate sales, customers and products data from ERP and CRM systems into a centralised data warehouse. This solution empowers business users with self-service analytics to:

- Uncover deep insights into customer behaviour and product performance.
- Identify and analyse key metrics that drive business decisions.
- Enable data-driven decision-making to boost profitability and customer retention.

---

## Building the Data Warehouse (Data Engineering)

### Solution Architecture

The project follows a three-layered Medallion Architecture, ensuring a clear and organised data flow from raw ingestion to a final, analytics-ready state.

___((((A visual representation of the data flow from source CSVs (ERP, CRM) through the Bronze, Silver, and Gold layers, culminating in Tableau dashboards.)))____

### Technical Stack
- **Database**: Microsoft SQL Server
- **Data Transformation & Analysis**: T-SQL (Stored Procedures, Views, CTEs, Window Functions)
- **Business Intelligence & Visualization**: Tableau (Tableau Public)

### The Data PipeLine (SQL)
The entire ETL (Extract, Transform, Load) process is automated using T-SQL stored procedures, creating an efficient and repeatable pipeline.

#### Bronze Layer: Raw Data Ingestion
Serves as the initial landing zone for raw, unaltered data from source CSVs.

- Creation of **'Bronze' layer tables**, primarily serving as the ingestion tables from the source datasets, without any transformations of modifications.
- A stored procedure automates data loading using the high-performance **BULK INSERT command**.

#### Silver Layer: ETL & Data Cleansing
This is the staging layer where data is cleansed, conformed, and integrated.
- **Process** : An **ETL** stored procedure transforms data from the Bronze layer.
- **Key Transformations**: Data type validation, handling of NULLs, business rule application, and joining of CRM and ERP data into an integrated tables consisting all the required information in one place.

#### Gold Layer: Business-Ready Dimensional Model
The final, analytics-optimised layer providing a single source of truth for reporting.
- **Design**: Implemented a **Star Schema** with dimension and fact tables to streamline analytical queries.
- **Implementation**: Created as **SQL Views**, refined it in the most business friendly format, ensuring business users always have real-time access to the most refined data.

---

## Analytics & Business Intelligence (BI)

### SQL-Driven Exploratory Data Analysis (EDA)
Two primary analytical reports were created as SQL Views on top of the Gold layer to serve key business functions.

#### Product Performance Report
- **Segmentation**: Classifies products into High-Performers, Mid-Range, and Low-Range tiers based on revenue.
- **Key Metrics**: Total Orders, Total Sales, Quantity Sold, Unique Customers.
- **Calculated KPIs**: Product Lifespan, Recency (months since last order), Average Order Revenue.

#### Customer Insights Report
- **Segmentation**: Groups customers into VIP, Regular, and New categories, along with age-based cohorts.
- **Key Metrics**:Total Orders, Total Sales, Quantity Purchased, Unique Products Bought.
- **Calculated KPIs**: Customer Lifespan, Recency, Average Order Value (AOV), Average Monthly Spend.

These insights empower stakeholders with key business metrics, enabling strategic decision-making.

---

## Interactive Tableau Dashboards
The refined data from the Gold layer was connected to Tableau to create a dynamic BI solution.

____((( GIF )))____

#### Dashboards Created
- **Sales Dashboard**: Provides a high-level overview of sales trends, geographical performance, and profit analysis by product category.

- **Customer Dashboard**: Focuses on customer segmentation, demographic analysis, and identifying top customers & products by sales and order volume.

#### Key Features
- **Interactive Filters**: Allows users to dynamically slice data by date, region, and product category.
- **Drill-Down Capabilities**: Enables exploration from a high-level summary to granular details.
- **Cross-Dashboard Navigation**: Seamlessly switch between the Sales and Customer views with interactive buttons.


---

## How to Run This Project

#### Pre-Requisites
- Microsoft SQL Server (2017 or later).
- SQL Server Management Studio (SSMS) - For Windows Operating System.
- Docker and Azure Data Studio (Recommended) - For MacOS and Linux Operating Systems.
- Note: If on MacOS/Linux device, make sure to create Volume Container while setting up your docker virtual environment to ensure smooth ingestion through BULK INSERT method.

#### Set-up & Execution
- Clone the repository.
- Create a database named *DataWarehouse*.
- Follow the numbered SQL scripts in the /Data-Warehouse/scripts folder to set up the schemas, tables, and stored procedures.
- Update the file paths in the proc_load_bronze.SQL script to your local CSV location.
- Execute the stored procedures to run the data pipeline.
- Query the Gold layer views to see the final, analytics-ready data.


---

## License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

---

## About Me

Hi there! my name is **Vipul Bharti**. Currently a fresher in this field and an undergraduate hailing from **IIT(BHU), Varanasi**, my work experience includes working as a **Data Analyst Intern** at **Noteables.in**, during my pre-final year at college.

I am an aspiring *Data Analyst* with a passion for uncovering the stories hidden within data. I believe that every dataset holds the potential to solve complex business problems, and my goal is to transform that raw data into clear, actionable insights.

This project is a practical demonstration of my skills in *SQL, data warehousing, ETL processes, and building intuitive BI dashboards with Tableau*. I am actively seeking opportunities where I can apply my analytical mindset and technical abilities to help organisations make smarter, data-driven decisions.

You can reach out to me via mail - *vipulbharti04@gmail.com*

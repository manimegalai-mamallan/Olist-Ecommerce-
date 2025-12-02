Ecommerce Data Warehouse – DBT Project

OLTP → Staging → Dimensions → Fact Model



This DBT project transforms raw transactional data from the Olist Ecommerce OLTP PostgreSQL database into a clean, analytics-ready Star Schema Data Warehouse.

It uses a layered approach:



Sources → Staging → Dimension Models → Fact Table



1\. Purpose of This Project

The goal of this DBT project is to:

&nbsp;	Clean and standardize OLTP data

&nbsp;	Create staging models for consistent schemas

&nbsp;	Build dimensional tables (customer, product, seller, date)

&nbsp;	Build a fact\_sales table at the grain of order item

&nbsp;	Prepare an OLAP-ready star schema for analytics and dashboards



2\. Project Structure

dbt/

│

├── models/

│   ├── sources.yml               

│   ├── staging/                 

│   │   ├── stg\_orders.sql

│   │   ├── stg\_customers.sql

│   │   ├── stg\_order\_items.sql

│   │   ├── stg\_order\_reviews.sql

│   │   ├── stg\_products.sql

│   │   ├── stg\_sellers.sql

│   │   └── stg\_geolocation.sql

│   │

│   ├── dim/                      

│   │   ├── dim\_customer.sql

│   │   ├── dim\_product.sql

│   │   ├── dim\_seller.sql

│   │   └── dim\_date.sql

│   │

│   ├── fact/                     

│   │   └── fact\_sales.sql

│   │

│   └── schema.yml                

│

├── dbt\_project.yml

└── packages.yml



3\. Star Schema Overview



Fact Table

&nbsp;	fact\_sales

&nbsp;	Grain: One row per order\_id + order\_item\_id

&nbsp;	Measures: price, freight\_value, revenue, delivery\_days

&nbsp;	Foreign Keys: customer\_key, product\_key, seller\_key, date\_key



Dimensions

&nbsp;	Dimension	Description

&nbsp;	dim\_customer	Customer demographics and geography

&nbsp;	dim\_product	Product details + category

&nbsp;	dim\_seller	Seller shop and location

&nbsp;	dim\_date	Calendar table with day/month/year/week



This schema supports revenue analysis, customer behavior analysis, delivery performance, category trends, and seller insights.



4\. DBT Sources Configuration



Defined in models/sources.yml:

sources:

&nbsp; - name: olist

&nbsp;   database: ecommerce

&nbsp;   schema: public

&nbsp;   tables:

&nbsp;     - name: orders

&nbsp;     - name: order\_items

&nbsp;     - name: customers

&nbsp;     - name: products

&nbsp;     - name: sellers

&nbsp;     - name: order\_reviews

&nbsp;     - name: product\_categories



8\. How to Run the Project



1\. Install dependencies

dbt deps



2\. Run all transformations

dbt run



3\. Run tests

dbt test



4\. Only run staging layer

dbt run --select stg\_\*



5\. Run dimensions + fact

dbt run --select dim\_\* fact\_sales



6\. Generate documentation

dbt docs generate

dbt docs serve



9\. Required DBT Profile



Add to:



~/.dbt/profiles.yml



ecommerce\_dwh:

&nbsp; target: dev

&nbsp; outputs:

&nbsp;   dev:

&nbsp;     type: postgres

&nbsp;     host: localhost

&nbsp;     user: postgres

&nbsp;     password: "Random2397!"

&nbsp;     port: 5432

&nbsp;     dbname: ecommerce

&nbsp;     schema: olist\_dw





stg\_\* → dim\_\* → fact\_sales



Run:



dbt docs generate

dbt docs serve


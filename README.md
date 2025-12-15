Olist E-Commerce Dashboard (OLTP & OLAP Integration)
1. Project Overview
This project shows an end-to-end analytics dashboard for the Olist Brazilian E-Commerce dataset, integrating OLTP and OLAP schemas using PostgreSQL and visualizing insights along a Streamlit web application. The system is containerized using Docker to make sure portability and reproducibility.
The dashboard authorizes users to investigate business metrics such as orders, customers, products, revenue, delivery performance, and category level insights through interactive filters.
________________________________________
2. Technology Stack
•	Database: PostgreSQL 15
•	Visualization: Streamlit
•	Backend Libraries are Python, Pandas, psycopg2
•	Containerization: Docker & Docker Compose
•	Deployment Environment: Local Docker setup
________________________________________
3. Project Structure
Phase3/
├─ docker-compose.yml
└─ app/
   ├─ Dockerfile
   ├─ requirements.txt
   ├─ app.py
   ├─ ingest.py
   │
   ├─ dataset/
   │  ├─ olist_customers_dataset.csv
   │  ├─ olist_geolocation_dataset.csv
   │  ├─ olist_order_items_dataset.csv
   │  ├─ olist_order_payments_dataset.csv
   │  ├─ olist_order_reviews_dataset.csv
   │  ├─ olist_orders_dataset.csv
   │  ├─ olist_products_dataset.csv
   │  ├─ olist_sellers_dataset.csv
   │  └─ product_category_name_translation.csv
   │
   ├─ models/
   │  ├─ run_all.sql
   │  ├─ stg/
   │  │  ├─ stg_customers.sql
   │  │  ├─ stg_geolocation.sql              (if you created/need it)
   │  │  ├─ stg_order_items.sql
   │  │  ├─ stg_order_payments.sql
   │  │  ├─ stg_order_reviews.sql
   │  │  ├─ stg_orders.sql
   │  │  ├─ stg_product_categories.sql
   │  │  ├─ stg_products.sql
   │  │  └─ stg_sellers.sql
   │  ├─ dim/
   │  │  ├─ dim_customer.sql
   │  │  ├─ dim_date.sql
   │  │  ├─ dim_product.sql
   │  │  └─ dim_seller.sql
   │  └─ fact/
   │     └─ fact_sales.sql
   │
   └─ pages/
      └─ 2_Delivery_SLA_Dashboard.py
________________________________________
4. Setup Instructions
Step 1: It is the Install Prerequisites
Verify the listed below are installed on your system:
•	Docker Desktop
•	Docker Compose
•	Python 3.9+ (for local testing, optional)
________________________________________
Step 2: Start Database Services
From the project root directory, run:
docker compose up -d
This will:
•	PostgreSQL on port 5432
•	Initializing OLTP and OLAP schemas
•	Persist data using Docker volumes
________________________________________
Step 3: Verify Database
Open Adminer in a browser:
http://localhost:8080
Login credentials:
•	System: PostgreSQL
•	Server: postgres
•	Username: postgres
•	Password: postgres
•	Database: ecommerce
Confirm that both OLTP and OLAP schemas exist.
________________________________________

5. Running the Streamlit Dashboard
Step 1 is Install Dependencies
pip install -r requirements.txt
Step 2 is Launch the Application
streamlit run app.py
Step 3: Access Dashboard
Open the browser at:
http://localhost:8501
________________________________________
6. Dashboard Features
•	Date range filtering
•	Product category filtering
•	Revenue and order metrics
•	Delivery performance indicators
•	OLTP vs OLAP analytics comparison
All filters update visualizations dynamically.
________________________________________
7. Stopping the Application
To stop all running containers:
docker compose down
________________________________________


8. Notes
•	The application uses environment-based database connections.
•	All SQL queries are optimized for analytical workloads.
•	The dashboard is designed for extensibility in future phases.
•	All members contributed equally to all the 3 Phase of this project from the design of the schema, ingestion logic, warehouse construction, dashboard development, and documentation.


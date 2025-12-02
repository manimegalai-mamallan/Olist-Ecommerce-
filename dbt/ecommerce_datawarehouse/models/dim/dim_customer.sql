-- models/dim/dim_customer.sql
-- Grain: one row per customer
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    customer_unique_id,
    customer_city      AS city,
    customer_state     AS state,
    customer_zip_code_prefix AS zip_prefix
FROM {{ ref('stg_customers') }};

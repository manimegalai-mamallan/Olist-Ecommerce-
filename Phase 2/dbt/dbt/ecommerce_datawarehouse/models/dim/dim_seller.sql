-- models/dim/dim_seller.sql
-- Grain: one row per seller
SELECT
    ROW_NUMBER() OVER (ORDER BY seller_id) AS seller_key,
    seller_id,
    seller_city      AS city,
    seller_state     AS state,
    seller_zip_code_prefix AS zip_prefix
FROM {{ ref('stg_sellers') }};

-- models/staging/stg_product_categories.sql
SELECT
    product_category_name,
    product_category_name_english
FROM {{ source('ecommerce', 'product_categories') }};

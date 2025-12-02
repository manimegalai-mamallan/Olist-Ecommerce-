-- models/dim/dim_product.sql
-- Grain: one row per product
WITH products AS (
    SELECT *
    FROM {{ ref('stg_products') }}
),
cats AS (
    SELECT *
    FROM {{ ref('stg_product_categories') }}
)
SELECT
    ROW_NUMBER() OVER (ORDER BY p.product_id) AS product_key,
    p.product_id,
    c.product_category_name_english,
    p.product_weight_g,
    p.product_photos_qty,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM products p
LEFT JOIN cats c
  ON p.product_category_name = c.product_category_name;

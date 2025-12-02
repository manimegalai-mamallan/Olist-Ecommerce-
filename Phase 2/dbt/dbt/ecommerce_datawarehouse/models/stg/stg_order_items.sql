-- models/staging/stg_order_items.sql
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date::timestamp AS shipping_limit_ts,
    price,
    freight_value
FROM {{ source('ecommerce', 'order_items') }};

-- models/staging/stg_orders.sql
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp::timestamp      AS order_purchase_ts,
    order_approved_at::timestamp             AS order_approved_ts,
    order_delivered_customer_date::timestamp AS delivered_ts,
    order_estimated_delivery_date::timestamp AS estimated_delivery_ts
FROM {{ source('ecommerce', 'orders') }};

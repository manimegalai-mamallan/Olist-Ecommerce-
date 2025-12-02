WITH
oi AS (
    SELECT *
    FROM {{ ref('stg_order_items') }}
),
o AS (
    SELECT *
    FROM {{ ref('stg_orders') }}
),
r AS (
    SELECT
        order_id,
        review_score
    FROM {{ ref('stg_order_reviews') }}
),
d_customer AS (
    SELECT customer_key, customer_id
    FROM {{ ref('dim_customer') }}
),
d_product AS (
    SELECT product_key, product_id
    FROM {{ ref('dim_product') }}
),
d_seller AS (
    SELECT seller_key, seller_id
    FROM {{ ref('dim_seller') }}
),
d_date AS (
    SELECT date_key, full_date
    FROM {{ ref('dim_date') }}
)

SELECT
    -- Let DB generate sales_key as identity if you created table separately.
    oi.order_id,
    oi.order_item_id,

    dc.customer_key,
    dp.product_key,
    ds.seller_key,
    dd.date_key AS order_date_key,

    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS revenue,
    r.review_score,

    CASE
        WHEN o.delivered_customer_ts IS NOT NULL
             AND o.estimated_delivery_ts IS NOT NULL
        THEN (o.delivered_customer_ts::date - o.estimated_delivery_ts::date)
        ELSE NULL
    END AS delivery_days

FROM oi
JOIN o
  ON o.order_id = oi.order_id
LEFT JOIN r
  ON r.order_id = o.order_id
JOIN d_customer dc
  ON dc.customer_id = o.customer_id
JOIN d_product dp
  ON dp.product_id = oi.product_id
JOIN d_seller ds
  ON ds.seller_id = oi.seller_id
JOIN d_date dd
  ON dd.full_date = o.order_purchase_ts::date;

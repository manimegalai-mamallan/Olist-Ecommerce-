-- Which sellers have the worst delivery delays relative to the promised estimated delivery date? --
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_estimated_delivery_date,
        o.order_delivered_customer_date,
        s.seller_id
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    JOIN sellers s
        ON s.seller_id = oi.seller_id
    WHERE o.order_status = 'delivered'
      AND o.order_delivered_customer_date IS NOT NULL
      AND o.order_estimated_delivery_date IS NOT NULL
),
seller_delay AS (
    SELECT
        seller_id,
        AVG(
            (order_delivered_customer_date::DATE
             - order_estimated_delivery_date::DATE)
        ) AS avg_delay_days,
        COUNT(DISTINCT order_id) AS num_delivered_orders
    FROM delivered_orders
    GROUP BY seller_id
)
SELECT
    seller_id,
    num_delivered_orders,
    avg_delay_days,
    NTILE(10) OVER (ORDER BY avg_delay_days) AS delay_decile
FROM seller_delay
WHERE num_delivered_orders >= 50        -- filter to meaningful volume
ORDER BY avg_delay_days DESC;
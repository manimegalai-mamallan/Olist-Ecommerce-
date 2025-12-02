-- For each monthly cohort of new customers, how many of them come back and place another order within 90 days? --
WITH first_orders AS (
    SELECT
        c.customer_unique_id,
        MIN(o.order_purchase_timestamp) AS first_order_ts
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    WHERE o.order_status IN ('delivered', 'shipped', 'invoiced')
    GROUP BY c.customer_unique_id
),
cohorts AS (
    SELECT
        customer_unique_id,
        DATE_TRUNC('month', first_order_ts) AS cohort_month,
        first_order_ts
    FROM first_orders
),
subsequent_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM customers c
    JOIN orders o
        ON o.customer_id = c.customer_id
    JOIN cohorts ch
        ON ch.customer_unique_id = c.customer_unique_id
    WHERE o.order_purchase_timestamp > ch.first_order_ts
      AND o.order_purchase_timestamp <= ch.first_order_ts + INTERVAL '90 days'
)
SELECT
    cohort_month,
    COUNT(DISTINCT subsequent_orders.customer_unique_id)                                    AS customers_in_cohort,
    COUNT(DISTINCT subsequent_orders.customer_unique_id)                  AS customers_with_repeat_90d,
    ROUND(
        COUNT(DISTINCT subsequent_orders.customer_unique_id)::NUMERIC
        / NULLIF(COUNT(DISTINCT cohorts.customer_unique_id), 0) * 100,
        2
    ) AS repeat_rate_90d_pct
FROM cohorts
LEFT JOIN subsequent_orders
    ON cohorts.customer_unique_id = subsequent_orders.customer_unique_id
GROUP BY cohort_month
ORDER BY cohort_month;
--Which product categories generate the most revenue, and how good are their review scores?--
WITH category_metrics AS (
    SELECT
        pc.product_category_name_english       AS category_name,
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        SUM(oi.price + oi.freight_value)       AS gross_revenue,
        COUNT(DISTINCT o.order_id)             AS num_orders,
        AVG(orv.review_score::NUMERIC)         AS avg_review_score
    FROM orders o
    JOIN order_items oi
        ON oi.order_id = o.order_id
    JOIN products p
        ON p.product_id = oi.product_id
    JOIN product_categories pc
        ON pc.category_id = p.category_id
    LEFT JOIN order_reviews orv
        ON orv.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        pc.product_category_name_english,
        DATE_TRUNC('month', o.order_purchase_timestamp)
)
SELECT
    category_name,
    order_month,
    gross_revenue,
    num_orders,
    avg_review_score,
    RANK() OVER (
        PARTITION BY order_month
        ORDER BY gross_revenue DESC
    ) AS revenue_rank_in_month
FROM category_metrics
ORDER BY order_month DESC, revenue_rank_in_month;
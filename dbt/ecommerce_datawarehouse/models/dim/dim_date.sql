-- models/dim/dim_date.sql
-- Grain: one row per calendar date
WITH dates AS (
    SELECT DISTINCT
        order_purchase_ts::date AS full_date
    FROM {{ ref('stg_orders') }}
)
SELECT
    CAST(TO_CHAR(full_date, 'YYYYMMDD') AS INTEGER) AS date_key,
    full_date,
    EXTRACT(YEAR  FROM full_date)::smallint   AS year,
    EXTRACT(QUARTER FROM full_date)::smallint AS quarter,
    EXTRACT(MONTH FROM full_date)::smallint   AS month,
    TO_CHAR(full_date, 'Month')               AS month_name,
    EXTRACT(DAY   FROM full_date)::smallint   AS day,
    EXTRACT(DOW   FROM full_date)::smallint   AS day_of_week,      -- 0–6
    TO_CHAR(full_date, 'Day')                 AS day_name,
    EXTRACT(WEEK  FROM full_date)::smallint   AS week_of_year,
    CASE WHEN EXTRACT(DOW FROM full_date) IN (0, 6) THEN TRUE ELSE FALSE END AS is_weekend
FROM dates;

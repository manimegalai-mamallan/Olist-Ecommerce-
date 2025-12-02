-- models/staging/stg_order_reviews.sql
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date::timestamp    AS review_creation_ts,
    review_answer_timestamp::timestamp AS review_answer_ts
FROM {{ source('ecommerce', 'order_reviews') }};

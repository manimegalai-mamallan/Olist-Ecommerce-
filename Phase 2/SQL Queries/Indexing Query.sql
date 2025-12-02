-- Accelerate date + status filter in orders
CREATE INDEX idx_orders_status_purchase_ts
    ON orders (order_status, order_purchase_timestamp);

-- Support joins from order_items to orders and products
-- PK (order_id, order_item_id)
CREATE INDEX idx_order_items_product_id
    ON order_items (product_id);

-- Support join from products to product_categories

CREATE INDEX idx_products_category_id
    ON products (category_id);

-- Support join from order_reviews to orders
CREATE INDEX idx_order_reviews_order_id
    ON order_reviews (order_id);

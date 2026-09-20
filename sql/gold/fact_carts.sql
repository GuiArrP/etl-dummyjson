CREATE TABLE IF NOT EXISTS gold.fact_carts (
    cart_id INTEGER PRIMARY KEY,
    user_id INTEGER NOT NULL,
    total NUMERIC(12,2),
    discounted_total NUMERIC(12,2),
    discount_amount NUMERIC(12,2),
    total_products INTEGER,
    total_quantity INTEGER,
    processed_timestamp TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT fk_fact_carts_user
        FOREIGN KEY (user_id)
        REFERENCES gold.dim_users(user_id)
);

INSERT INTO gold.fact_carts (
    cart_id,
    user_id,
    total,
    discounted_total,
    discount_amount,
    total_products,
    total_quantity
)
SELECT
    cart_id,
    user_id,
    total,
    discounted_total,
    total - discounted_total AS discount_amount,
    total_products,
    total_quantity
FROM silver.carts
ON CONFLICT (cart_id)
DO UPDATE SET
    user_id = EXCLUDED.user_id,
    total = EXCLUDED.total,
    discounted_total = EXCLUDED.discounted_total,
    discount_amount = EXCLUDED.discount_amount,
    total_products = EXCLUDED.total_products,
    total_quantity = EXCLUDED.total_quantity,
    processed_timestamp = NOW();
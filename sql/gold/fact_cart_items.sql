CREATE TABLE IF NOT EXISTS gold.fact_cart_items (
    cart_id INTEGER NOT NULL,
    item_sequence INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER,
    unit_price NUMERIC(12,2),
    discounted_unit_price NUMERIC(12,2),
    gross_value NUMERIC(12,2),
    discounted_value NUMERIC(12,2),
    discount_value NUMERIC(12,2),
    processed_timestamp TIMESTAMPTZ DEFAULT NOW(),

    PRIMARY KEY (cart_id, item_sequence),

    CONSTRAINT fk_fact_cart_items_cart
        FOREIGN KEY (cart_id)
        REFERENCES gold.fact_carts(cart_id),

    CONSTRAINT fk_fact_cart_items_product
        FOREIGN KEY (product_id)
        REFERENCES gold.dim_products(product_id)
);

INSERT INTO gold.fact_cart_items (
    cart_id,
    item_sequence,
    product_id,
    quantity,
    unit_price,
    discounted_unit_price,
    gross_value,
    discounted_value,
    discount_value
)
SELECT
    ci.cart_id,
    ci.item_sequence,
    ci.product_id,
    ci.quantity,
    ci.price,
    ci.discounted_price,

    ci.quantity * ci.price AS gross_value,

    CASE
        WHEN ci.discounted_price IS NOT NULL
        THEN ci.quantity * ci.discounted_price
        ELSE NULL
    END AS discounted_value,

    CASE
        WHEN ci.discounted_price IS NOT NULL
        THEN ci.quantity * (ci.price - ci.discounted_price)
        ELSE NULL
    END AS discount_value

FROM silver.cart_items ci

ON CONFLICT (cart_id, item_sequence)
DO UPDATE SET
    product_id = EXCLUDED.product_id,
    quantity = EXCLUDED.quantity,
    unit_price = EXCLUDED.unit_price,
    discounted_unit_price = EXCLUDED.discounted_unit_price,
    gross_value = EXCLUDED.gross_value,
    discounted_value = EXCLUDED.discounted_value,
    discount_value = EXCLUDED.discount_value,
    processed_timestamp = NOW();
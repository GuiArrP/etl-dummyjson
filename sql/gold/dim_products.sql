CREATE TABLE IF NOT EXISTS gold.dim_products (
    product_id INTEGER PRIMARY KEY,
    title VARCHAR(255),
    category VARCHAR(100),
    brand VARCHAR(100),
    sku VARCHAR(100),
    price NUMERIC(12,2),
    rating NUMERIC(5,2),
    stock INTEGER,
    availability_status VARCHAR(100),
    processed_timestamp TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO gold.dim_products (
    product_id,
    title,
    category,
    brand,
    sku,
    price,
    rating,
    stock,
    availability_status
)
SELECT
    product_id,
    title,
    category,
    brand,
    sku,
    price,
    rating,
    stock,
    availability_status
FROM silver.products
ON CONFLICT (product_id)
DO UPDATE SET
    title = EXCLUDED.title,
    category = EXCLUDED.category,
    brand = EXCLUDED.brand,
    sku = EXCLUDED.sku,
    price = EXCLUDED.price,
    rating = EXCLUDED.rating,
    stock = EXCLUDED.stock,
    availability_status = EXCLUDED.availability_status,
    processed_timestamp = NOW();
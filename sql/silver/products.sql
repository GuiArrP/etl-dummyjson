INSERT INTO silver.products (
    product_id,
    title,
    description,
    category,
    price,
    discount_percentage,
    rating,
    stock,
    brand,
    sku,
    availability_status,
    return_policy,
    minimum_order_quantity,
    ingestion_timestamp
)

SELECT
    source_id AS product_id,
    raw_data ->> 'title' AS title,
    raw_data ->> 'description' AS description,
    raw_data ->> 'category' AS category,
    (raw_data ->> 'price')::NUMERIC(12,2) AS price,
    (raw_data ->> 'discountPercentage')::NUMERIC(10,2) AS discount_percentage,
    (raw_data ->> 'rating')::NUMERIC(5,2) AS rating,
    (raw_data ->> 'stock')::INTEGER AS stock,
    raw_data ->> 'brand' AS brand,
    raw_data ->> 'sku' AS sku,
    raw_data ->> 'availabilityStatus' AS availability_status,
    raw_data ->> 'returnPolicy' AS return_policy,
    (raw_data ->> 'minimumOrderQuantity')::INTEGER AS minimum_order_quantity,
    ingestion_timestamp

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY source_id
            ORDER BY ingestion_timestamp DESC, ingestion_id DESC
        ) AS rn
    FROM bronze.products_raw
) latest

WHERE rn = 1

ON CONFLICT (product_id)

DO UPDATE SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    category = EXCLUDED.category,
    price = EXCLUDED.price,
    discount_percentage = EXCLUDED.discount_percentage,
    rating = EXCLUDED.rating,
    stock = EXCLUDED.stock,
    brand = EXCLUDED.brand,
    sku = EXCLUDED.sku,
    availability_status = EXCLUDED.availability_status,
    return_policy = EXCLUDED.return_policy,
    minimum_order_quantity = EXCLUDED.minimum_order_quantity,
    ingestion_timestamp = EXCLUDED.ingestion_timestamp,
    processed_timestamp = NOW();
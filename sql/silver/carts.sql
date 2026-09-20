INSERT INTO silver.carts (
    cart_id,
    user_id,
    total,
    discounted_total,
    total_products,
    total_quantity,
    ingestion_timestamp
)

SELECT
    source_id AS cart_id,

    (raw_data ->> 'userId')::INTEGER AS user_id,

    (raw_data ->> 'total')::NUMERIC(12,2) AS total,

    (raw_data ->> 'discountedTotal')::NUMERIC(12,2)
        AS discounted_total,

    (raw_data ->> 'totalProducts')::INTEGER
        AS total_products,

    (raw_data ->> 'totalQuantity')::INTEGER
        AS total_quantity,

    ingestion_timestamp

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY source_id
            ORDER BY ingestion_timestamp DESC, ingestion_id DESC
        ) AS rn
    FROM bronze.carts_raw
) latest

WHERE rn = 1

ON CONFLICT (cart_id)

DO UPDATE SET
    user_id = EXCLUDED.user_id,
    total = EXCLUDED.total,
    discounted_total = EXCLUDED.discounted_total,
    total_products = EXCLUDED.total_products,
    total_quantity = EXCLUDED.total_quantity,
    ingestion_timestamp = EXCLUDED.ingestion_timestamp,
    processed_timestamp = NOW();
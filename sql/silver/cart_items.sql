INSERT INTO silver.cart_items (
    cart_id,
    item_sequence,
    product_id,
    quantity,
    price,
    discounted_price,
    ingestion_timestamp
)

SELECT
    latest.source_id AS cart_id,

    item.item_sequence,

    (item.product ->> 'id')::INTEGER AS product_id,

    (item.product ->> 'quantity')::INTEGER AS quantity,

    (item.product ->> 'price')::NUMERIC(12,2) AS price,

    (item.product ->> 'discountedPrice')::NUMERIC(12,2)
        AS discounted_price,

    latest.ingestion_timestamp

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY source_id
            ORDER BY ingestion_timestamp DESC, ingestion_id DESC
        ) AS rn

    FROM bronze.carts_raw
) latest

CROSS JOIN LATERAL
    jsonb_array_elements(
        latest.raw_data -> 'products'
    ) WITH ORDINALITY AS item(product, item_sequence)

WHERE latest.rn = 1

ON CONFLICT (cart_id, item_sequence)

DO UPDATE SET
    product_id = EXCLUDED.product_id,
    quantity = EXCLUDED.quantity,
    price = EXCLUDED.price,
    discounted_price = EXCLUDED.discounted_price,
    ingestion_timestamp = EXCLUDED.ingestion_timestamp,
    processed_timestamp = NOW();
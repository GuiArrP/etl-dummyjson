from sqlalchemy import text

from src.transform.postgres import engine


def run_query(query):
    """
    Executa uma query de qualidade e retorna
    a quantidade de registros encontrados.
    """

    with engine.begin() as connection:
        result = connection.execute(text(query))

        return result.rowcount


def check_duplicate_products():
    query = """
        SELECT product_id
        FROM silver.products
        GROUP BY product_id
        HAVING COUNT(*) > 1;
    """

    return run_query(query)


def check_duplicate_users():
    query = """
        SELECT user_id
        FROM silver.users
        GROUP BY user_id
        HAVING COUNT(*) > 1;
    """

    return run_query(query)


def check_duplicate_carts():
    query = """
        SELECT cart_id
        FROM silver.carts
        GROUP BY cart_id
        HAVING COUNT(*) > 1;
    """

    return run_query(query)


def check_duplicate_cart_items():
    query = """
        SELECT
            cart_id,
            item_sequence
        FROM silver.cart_items
        GROUP BY
            cart_id,
            item_sequence
        HAVING COUNT(*) > 1;
    """

    return run_query(query)


def check_carts_without_users():
    query = """
        SELECT
            c.cart_id
        FROM silver.carts c
        LEFT JOIN silver.users u
            ON c.user_id = u.user_id
        WHERE u.user_id IS NULL;
    """

    return run_query(query)


def check_cart_items_without_products():
    query = """
        SELECT
            ci.cart_id,
            ci.item_sequence
        FROM silver.cart_items ci
        LEFT JOIN silver.products p
            ON ci.product_id = p.product_id
        WHERE p.product_id IS NULL;
    """

    return run_query(query)


def check_cart_items_without_carts():
    query = """
        SELECT
            ci.cart_id,
            ci.item_sequence
        FROM silver.cart_items ci
        LEFT JOIN silver.carts c
            ON ci.cart_id = c.cart_id
        WHERE c.cart_id IS NULL;
    """

    return run_query(query)


def check_invalid_product_prices():
    query = """
        SELECT product_id
        FROM silver.products
        WHERE price IS NULL
           OR price < 0;
    """

    return run_query(query)


def check_invalid_cart_item_quantities():
    query = """
        SELECT
            cart_id,
            item_sequence
        FROM silver.cart_items
        WHERE quantity IS NULL
           OR quantity <= 0;
    """

    return run_query(query)


def check_invalid_cart_item_prices():
    query = """
        SELECT
            cart_id,
            item_sequence
        FROM silver.cart_items
        WHERE price IS NULL
           OR price < 0
           OR (
                discounted_price IS NOT NULL
                AND discounted_price < 0
           );
    """

    return run_query(query)

def run_quality_checks():

    checks = [
        (
            "Duplicate Products",
            check_duplicate_products
        ),
        (
            "Duplicate Users",
            check_duplicate_users
        ),
        (
            "Duplicate Carts",
            check_duplicate_carts
        ),
        (
            "Duplicate Cart Items",
            check_duplicate_cart_items
        ),
        (
            "Carts without Users",
            check_carts_without_users
        ),
        (
            "Cart Items without Products",
            check_cart_items_without_products
        ),
        (
            "Cart Items without Carts",
            check_cart_items_without_carts
        ),
        (
            "Invalid Product Prices",
            check_invalid_product_prices
        ),
        (
            "Invalid Cart Item Quantities",
            check_invalid_cart_item_quantities
        ),
        (
            "Invalid Cart Item Prices",
            check_invalid_cart_item_prices
        ),
    ]

    results = []

    for name, check_function in checks:

        errors = check_function()

        results.append(
            {
                "name": name,
                "errors": errors,
                "status": "PASS" if errors == 0 else "FAIL"
            }
        )

    return results
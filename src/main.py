from src.extract.api import get_data
from src.load.postgres import load_to_bronze


API_BASE_URL = "https://dummyjson.com"


def main():

    print("=" * 50)
    print("INICIANDO PIPELINE - BRONZE")
    print("=" * 50)

    # =========================
    # PRODUCTS
    # =========================

    print("\n[1/3] Extraindo Products...")

    products = get_data(
        url=f"{API_BASE_URL}/products",
        data_key="products"
    )

    print(f"Produtos extraídos: {len(products)}")

    batch_products = load_to_bronze(
        data=products,
        table_name="products_raw",
        id_field="id"
    )

    print(f"Products carregados | Batch: {batch_products}")


    # =========================
    # USERS
    # =========================

    print("\n[2/3] Extraindo Users...")

    users = get_data(
        url=f"{API_BASE_URL}/users",
        data_key="users"
    )

    print(f"Usuários extraídos: {len(users)}")

    batch_users = load_to_bronze(
        data=users,
        table_name="users_raw",
        id_field="id"
    )

    print(f"Users carregados | Batch: {batch_users}")


    # =========================
    # CARTS
    # =========================

    print("\n[3/3] Extraindo Carts...")

    carts = get_data(
        url=f"{API_BASE_URL}/carts",
        data_key="carts"
    )

    print(f"Carts extraídos: {len(carts)}")

    batch_carts = load_to_bronze(
        data=carts,
        table_name="carts_raw",
        id_field="id"
    )

    print(f"Carts carregados | Batch: {batch_carts}")


    print("\n" + "=" * 50)
    print("PIPELINE BRONZE FINALIZADO")
    print("=" * 50)


if __name__ == "__main__":
    main()
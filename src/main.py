from pathlib import Path

from sqlalchemy import text

from src.config.sources import SOURCES
from src.extract.api import get_data
from src.load.postgres import load_to_bronze
from src.quality.checks import run_quality_checks
from src.transform.postgres import engine, execute_sql_file
from src.utils.logger import setup_logger


PROJECT_ROOT = Path(__file__).resolve().parent.parent

SQL_SILVER_PATH = PROJECT_ROOT / "sql" / "silver"
SQL_GOLD_PATH = PROJECT_ROOT / "sql" / "gold"

logger = setup_logger()


def run_bronze():
    logger.info("=" * 60)
    logger.info("INICIANDO ETAPA BRONZE")
    logger.info("=" * 60)

    for source in SOURCES:
        name = source["name"]

        logger.info("[%s] Extraindo dados...", name)

        data = get_data(
            url=source["url"],
            data_key=source["data_key"]
        )

        logger.info(
            "[%s] Registros extraídos: %s",
            name,
            len(data)
        )

        batch_id = load_to_bronze(
            data=data,
            table_name=source["bronze_table"],
            id_field=source["id_field"]
        )

        logger.info(
            "[%s] Registros carregados: %s",
            name,
            len(data)
        )

        logger.info(
            "[%s] Batch ID: %s",
            name,
            batch_id
        )


def run_silver():
    logger.info("=" * 60)
    logger.info("INICIANDO ETAPA SILVER")
    logger.info("=" * 60)

    sql_files = [
        "products.sql",
        "users.sql",
        "carts.sql",
        "cart_items.sql",
    ]

    for sql_file in sql_files:
        file_path = SQL_SILVER_PATH / sql_file

        logger.info(
            "Executando transformação: %s",
            sql_file
        )

        execute_sql_file(file_path)

        logger.info(
            "Transformação concluída: %s",
            sql_file
        )


def log_silver_counts():
    logger.info("=" * 60)
    logger.info("CONTAGEM DE REGISTROS - SILVER")
    logger.info("=" * 60)

    queries = {
        "Products": "SELECT COUNT(*) FROM silver.products",
        "Users": "SELECT COUNT(*) FROM silver.users",
        "Carts": "SELECT COUNT(*) FROM silver.carts",
        "Cart Items": "SELECT COUNT(*) FROM silver.cart_items",
    }

    with engine.begin() as connection:
        for name, query in queries.items():
            count = connection.execute(text(query)).scalar()

            logger.info(
                "%s: %s registros",
                name,
                count
            )


def run_quality():
    logger.info("=" * 60)
    logger.info("INICIANDO DATA QUALITY")
    logger.info("=" * 60)

    results = run_quality_checks()

    has_errors = False

    for result in results:
        if result["status"] == "PASS":
            logger.info(
                "[PASS] %s | %s registros",
                result["name"],
                result["errors"]
            )
        else:
            has_errors = True

            logger.error(
                "[FAIL] %s | %s registros",
                result["name"],
                result["errors"]
            )

    if has_errors:
        raise RuntimeError(
            "Data Quality encontrou problemas."
        )

    logger.info("DATA QUALITY: PASS")


def run_gold():
    logger.info("=" * 60)
    logger.info("INICIANDO ETAPA GOLD")
    logger.info("=" * 60)

    sql_files = [
        "dim_users.sql",
        "dim_products.sql",
        "fact_carts.sql",
        "fact_cart_items.sql",
    ]

    for sql_file in sql_files:
        file_path = SQL_GOLD_PATH / sql_file

        logger.info(
            "Executando transformação: %s",
            sql_file
        )

        execute_sql_file(file_path)

        logger.info(
            "Transformação concluída: %s",
            sql_file
        )


def log_gold_counts():
    logger.info("=" * 60)
    logger.info("CONTAGEM DE REGISTROS - GOLD")
    logger.info("=" * 60)

    queries = {
        "Dim Users": "SELECT COUNT(*) FROM gold.dim_users",
        "Dim Products": "SELECT COUNT(*) FROM gold.dim_products",
        "Fact Carts": "SELECT COUNT(*) FROM gold.fact_carts",
        "Fact Cart Items": "SELECT COUNT(*) FROM gold.fact_cart_items",
    }

    with engine.begin() as connection:
        for name, query in queries.items():
            count = connection.execute(text(query)).scalar()

            logger.info(
                "%s: %s registros",
                name,
                count
            )


def main():
    logger.info("")
    logger.info("=" * 60)
    logger.info("INICIANDO ETL")
    logger.info("=" * 60)

    try:
        run_bronze()
        run_silver()
        log_silver_counts()
        run_quality()
        run_gold()
        log_gold_counts()

        logger.info("=" * 60)
        logger.info("PIPELINE EXECUTADO COM SUCESSO")
        logger.info("=" * 60)

    except Exception:
        logger.exception(
            "ERRO DURANTE A EXECUÇÃO DO PIPELINE"
        )
        raise


if __name__ == "__main__":
    main()
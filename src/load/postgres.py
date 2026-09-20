import os

from uuid import uuid4

from dotenv import load_dotenv
from sqlalchemy import create_engine, MetaData, Table


load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)


def load_to_bronze(data, table_name, id_field):

    batch_id = uuid4()

    metadata = MetaData()

    table = Table(
        table_name,
        metadata,
        schema="bronze",
        autoload_with=engine
    )

    rows = [
        {
            "batch_id": batch_id,
            "source_id": item[id_field],
            "raw_data": item
        }
        for item in data
    ]

    with engine.begin() as connection:
        connection.execute(
            table.insert(),
            rows
        )

    return batch_id
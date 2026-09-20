import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)


def execute_sql_file(file_path):
    with open(file_path, "r", encoding="utf-8") as file:
        sql = file.read()

    with engine.begin() as connection:
        connection.execute(text(sql))
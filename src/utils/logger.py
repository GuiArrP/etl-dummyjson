import logging
from datetime import datetime
from pathlib import Path


def setup_logger():

    project_root = Path(__file__).resolve().parent.parent.parent

    logs_path = project_root / "logs"

    logs_path.mkdir(exist_ok=True)

    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")

    log_file = logs_path / f"pipeline_{timestamp}.log"

    logger = logging.getLogger("etl_dummyjson")

    logger.setLevel(logging.INFO)

    # Evita adicionar handlers duplicados
    if logger.handlers:
        return logger

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S"
    )

    # --------------------------------------------------------
    # Arquivo
    # --------------------------------------------------------

    file_handler = logging.FileHandler(
        log_file,
        encoding="utf-8"
    )

    file_handler.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)

    # --------------------------------------------------------
    # Terminal
    # --------------------------------------------------------

    console_handler = logging.StreamHandler()

    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    # --------------------------------------------------------
    # Handlers
    # --------------------------------------------------------

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger
import os
from urllib.parse import quote_plus

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker


load_dotenv()


DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    db_host = os.getenv("DB_HOST")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")

    required = {
        "DB_HOST": db_host,
        "DB_NAME": db_name,
        "DB_USER": db_user,
        "DB_PASSWORD": db_password,
    }

    missing = [
        name
        for name, value in required.items()
        if not value
    ]

    if missing:
        raise RuntimeError(
            f"Database configuration missing: {', '.join(missing)}"
        )

    DATABASE_URL = (
        f"postgresql+psycopg2://"
        f"{quote_plus(db_user)}:"
        f"{quote_plus(db_password)}@"
        f"{db_host}:{db_port}/"
        f"{db_name}"
    )


engine = create_engine(DATABASE_URL)


SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)


Base = declarative_base()


def get_db():
    db = SessionLocal()

    try:
        yield db
    finally:
        db.close()
from database import Base, engine

# Import models so SQLAlchemy knows which tables belong to Base.metadata.
from models import TicketDB  # noqa: F401


def run_migration():
    print("Running TicketDesk database schema migration...")

    Base.metadata.create_all(bind=engine)

    print("TicketDesk database schema migration completed.")


if __name__ == "__main__":
    run_migration()
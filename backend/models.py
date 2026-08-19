from sqlalchemy import Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from pydantic import BaseModel

from backend.database import Base


class TicketDB(Base):
    __tablename__ = "tickets"

    id: Mapped[int] = mapped_column(
        Integer,
        primary_key=True,
        index=True
    )

    title: Mapped[str] = mapped_column(
        String(200),
        nullable=False
    )

    description: Mapped[str] = mapped_column(
        Text,
        nullable=False
    )

    priority: Mapped[str] = mapped_column(
        String(20),
        default="medium"
    )

    status: Mapped[str] = mapped_column(
        String(20),
        default="open"
    )


class TicketCreate(BaseModel):
    title: str
    description: str
    priority: str = "medium"
    status: str = "open"


class TicketUpdate(BaseModel):
    title: str
    description: str
    priority: str
    status: str
from pydantic import BaseModel
from sqlalchemy import Column, Integer, String

from database import Base


class TicketDB(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    priority = Column(String, nullable=False, default="medium")
    status = Column(String, nullable=False, default="open")


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


class TicketResponse(BaseModel):
    id: int
    title: str
    description: str
    priority: str
    status: str

    model_config = {
        "from_attributes": True
    }
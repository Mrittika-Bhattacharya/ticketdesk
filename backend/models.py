from pydantic import BaseModel


class TicketCreate(BaseModel):
    title: str
    description: str
    priority: str = "medium"
    status: str = "open"


class Ticket(TicketCreate):
    id: int
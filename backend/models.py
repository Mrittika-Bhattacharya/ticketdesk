from pydantic import BaseModel
from typing import Optional


class Ticket(BaseModel):
    title: str
    description: str
    priority: str = "medium"
    status: str = "open"
from fastapi import FastAPI

from models import Ticket, TicketCreate, TicketUpdate
from database import tickets, get_next_ticket_id


app = FastAPI(
    title="TicketDesk API",
    description="Backend API for the TicketDesk POC",
    version="1.0.0"
)


@app.get("/")
def home():
    return {
        "message": "TicketDesk API is running!"
    }


@app.get("/health")
def health():
    return {
        "status": "healthy"
    }


@app.post("/tickets")
def create_ticket(ticket: TicketCreate):
    new_ticket = Ticket(
        id=get_next_ticket_id(),
        title=ticket.title,
        description=ticket.description,
        priority=ticket.priority,
        status=ticket.status
    )

    tickets.append(new_ticket)

    return {
        "message": "Ticket created successfully",
        "ticket": new_ticket
    }


@app.get("/tickets")
def get_tickets():
    return {
        "tickets": tickets
    }


@app.get("/tickets/{ticket_id}")
def get_ticket(ticket_id: int):
    for ticket in tickets:
        if ticket.id == ticket_id:
            return ticket

    return {
        "message": "Ticket not found"
    }


@app.put("/tickets/{ticket_id}")
def update_ticket(ticket_id: int, updated_ticket: TicketUpdate):
    for ticket in tickets:
        if ticket.id == ticket_id:
            ticket.title = updated_ticket.title
            ticket.description = updated_ticket.description
            ticket.priority = updated_ticket.priority
            ticket.status = updated_ticket.status

            return {
                "message": "Ticket updated successfully",
                "ticket": ticket
            }

    return {
        "message": "Ticket not found"
    }


@app.delete("/tickets/{ticket_id}")
def delete_ticket(ticket_id: int):
    for ticket in tickets:
        if ticket.id == ticket_id:
            tickets.remove(ticket)

            return {
                "message": "Ticket deleted successfully"
            }

    return {
        "message": "Ticket not found"
    }

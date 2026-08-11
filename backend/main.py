from fastapi import FastAPI

from models import Ticket, TicketCreate


app = FastAPI(
    title="TicketDesk API",
    description="Backend API for the TicketDesk POC",
    version="1.0.0"
)


# Temporary in-memory storage
tickets = []

# Temporary ID generator
next_ticket_id = 1


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
    global next_ticket_id

    new_ticket = Ticket(
        id=next_ticket_id,
        title=ticket.title,
        description=ticket.description,
        priority=ticket.priority,
        status=ticket.status
    )

    tickets.append(new_ticket)

    next_ticket_id += 1

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
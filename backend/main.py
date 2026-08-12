from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from models import TicketCreate, TicketDB, TicketUpdate


Base.metadata.create_all(bind=engine)


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
def create_ticket(
    ticket: TicketCreate,
    db: Session = Depends(get_db)
):
    new_ticket = TicketDB(
        title=ticket.title,
        description=ticket.description,
        priority=ticket.priority,
        status=ticket.status
    )

    db.add(new_ticket)
    db.commit()
    db.refresh(new_ticket)

    return {
        "message": "Ticket created successfully",
        "ticket": new_ticket
    }


@app.get("/tickets")
def get_tickets(
    db: Session = Depends(get_db)
):
    tickets = db.query(TicketDB).all()

    return {
        "tickets": tickets
    }


@app.get("/tickets/{ticket_id}")
def get_ticket(
    ticket_id: int,
    db: Session = Depends(get_db)
):
    ticket = (
        db.query(TicketDB)
        .filter(TicketDB.id == ticket_id)
        .first()
    )

    if ticket is None:
        return {
            "message": "Ticket not found"
        }

    return ticket


@app.put("/tickets/{ticket_id}")
def update_ticket(
    ticket_id: int,
    updated_ticket: TicketUpdate,
    db: Session = Depends(get_db)
):
    ticket = (
        db.query(TicketDB)
        .filter(TicketDB.id == ticket_id)
        .first()
    )

    if ticket is None:
        return {
            "message": "Ticket not found"
        }

    ticket.title = updated_ticket.title
    ticket.description = updated_ticket.description
    ticket.priority = updated_ticket.priority
    ticket.status = updated_ticket.status

    db.commit()
    db.refresh(ticket)

    return {
        "message": "Ticket updated successfully",
        "ticket": ticket
    }


@app.delete("/tickets/{ticket_id}")
def delete_ticket(
    ticket_id: int,
    db: Session = Depends(get_db)
):
    ticket = (
        db.query(TicketDB)
        .filter(TicketDB.id == ticket_id)
        .first()
    )

    if ticket is None:
        return {
            "message": "Ticket not found"
        }

    db.delete(ticket)
    db.commit()

    return {
        "message": "Ticket deleted successfully"
    }
from fastapi import FastAPI
from models import Ticket

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
def create_ticket(ticket: Ticket):
    return {
        "message": "Ticket created successfully",
        "ticket": ticket
    }
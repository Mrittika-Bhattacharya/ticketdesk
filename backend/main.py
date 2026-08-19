import os
from pathlib import PurePosixPath

import boto3
from botocore.exceptions import BotoCoreError, ClientError
from fastapi import APIRouter, Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from backend.database import get_db
from backend.models import TicketCreate, TicketDB, TicketUpdate


app = FastAPI(
    title="TicketDesk API",
    description="Backend API for the TicketDesk POC",
    version="1.0.0"
)

api = APIRouter(prefix="/api")

s3_client = boto3.client("s3")
ATTACHMENTS_BUCKET = os.environ.get("ATTACHMENTS_BUCKET")


def attachment_filename(filename: str) -> str:
    # Keep only the final filename component and reject empty/path-like names.
    safe_name = PurePosixPath(filename.replace("\\", "/")).name
    if not safe_name or safe_name in {".", ".."}:
        raise HTTPException(status_code=400, detail="Invalid filename")
    return safe_name


@app.get("/")
def home():
    return {"message": "TicketDesk API is running!"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@api.get("/health")
def api_health():
    return {"status": "healthy"}


@api.post("/tickets", status_code=201)
def create_ticket(ticket: TicketCreate, db: Session = Depends(get_db)):
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
        "ticket": {
            "id": new_ticket.id,
            "title": new_ticket.title,
            "description": new_ticket.description,
            "priority": new_ticket.priority,
            "status": new_ticket.status
        }
    }


@api.get("/tickets")
def get_tickets(db: Session = Depends(get_db)):
    tickets = db.query(TicketDB).all()
    return {
        "tickets": [
            {
                "id": ticket.id,
                "title": ticket.title,
                "description": ticket.description,
                "priority": ticket.priority,
                "status": ticket.status
            }
            for ticket in tickets
        ]
    }


@api.get("/tickets/{ticket_id}")
def get_ticket(ticket_id: int, db: Session = Depends(get_db)):
    ticket = db.get(TicketDB, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")

    return {
        "id": ticket.id,
        "title": ticket.title,
        "description": ticket.description,
        "priority": ticket.priority,
        "status": ticket.status
    }


@api.put("/tickets/{ticket_id}")
def update_ticket(
    ticket_id: int,
    updated_ticket: TicketUpdate,
    db: Session = Depends(get_db)
):
    ticket = db.get(TicketDB, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")

    ticket.title = updated_ticket.title
    ticket.description = updated_ticket.description
    ticket.priority = updated_ticket.priority
    ticket.status = updated_ticket.status

    db.commit()
    db.refresh(ticket)

    return {
        "message": "Ticket updated successfully",
        "ticket": {
            "id": ticket.id,
            "title": ticket.title,
            "description": ticket.description,
            "priority": ticket.priority,
            "status": ticket.status
        }
    }


@api.delete("/tickets/{ticket_id}")
def delete_ticket(ticket_id: int, db: Session = Depends(get_db)):
    ticket = db.get(TicketDB, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")

    db.delete(ticket)
    db.commit()

    return {"message": "Ticket deleted successfully"}


@api.post("/tickets/{ticket_id}/attachments/presigned-url")
def create_attachment_upload_url(
    ticket_id: int,
    filename: str,
    content_type: str,
    db: Session = Depends(get_db)
):
    ticket = db.get(TicketDB, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if not ATTACHMENTS_BUCKET:
        raise HTTPException(
            status_code=500,
            detail="Attachment bucket is not configured"
        )

    if not content_type.startswith("image/"):
        raise HTTPException(
            status_code=400,
            detail="Only image attachments are supported"
        )

    safe_name = attachment_filename(filename)
    key = f"originals/tickets/{ticket_id}/{safe_name}"

    try:
        upload_url = s3_client.generate_presigned_url(
            ClientMethod="put_object",
            Params={
                "Bucket": ATTACHMENTS_BUCKET,
                "Key": key,
                "ContentType": content_type
            },
            ExpiresIn=900
        )
    except (BotoCoreError, ClientError) as exc:
        raise HTTPException(
            status_code=500,
            detail="Unable to generate upload URL"
        ) from exc

    return {
        "upload_url": upload_url,
        "key": key,
        "bucket": ATTACHMENTS_BUCKET
    }


@api.get("/tickets/{ticket_id}/attachments/thumbnail-url")
def get_thumbnail_url(ticket_id: int, filename: str, db: Session = Depends(get_db)):
    ticket = db.get(TicketDB, ticket_id)
    if ticket is None:
        raise HTTPException(status_code=404, detail="Ticket not found")

    if not ATTACHMENTS_BUCKET:
        raise HTTPException(
            status_code=500,
            detail="Attachment bucket is not configured"
        )

    safe_name = attachment_filename(filename)
    key = f"thumbnails/tickets/{ticket_id}/{safe_name}"

    try:
        s3_client.head_object(
            Bucket=ATTACHMENTS_BUCKET,
            Key=key
        )
        url = s3_client.generate_presigned_url(
            ClientMethod="get_object",
            Params={
                "Bucket": ATTACHMENTS_BUCKET,
                "Key": key
            },
            ExpiresIn=900
        )
    except ClientError as exc:
        error_code = exc.response.get("Error", {}).get("Code")
        if error_code in {"404", "NoSuchKey", "NotFound"}:
            return {"ready": False, "key": key}
        raise HTTPException(
            status_code=500,
            detail="Unable to check thumbnail"
        ) from exc

    return {
        "ready": True,
        "key": key,
        "thumbnail_url": url
    }


app.include_router(api)

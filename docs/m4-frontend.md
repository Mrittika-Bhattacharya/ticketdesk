# M4 - Frontend Integration

## Status

**Completed - Alternative Implementation**

The TicketDesk static frontend was deployed to S3 and exposed through API Gateway. The frontend successfully reads and creates tickets through the deployed `/prod/api` path.

> **Architecture note:** The original POC brief specifies CloudFront + private S3 with `/api/*` routed to the load balancer. The implementation documented here uses **S3 + API Gateway** instead. It should therefore be described as the project's **alternative M4 implementation**, not as the exact CloudFront architecture from the brief.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## Frontend

The frontend consists of:

```text
index.html
styles.css
app.js
```

The files are stored in the TicketDesk frontend S3 bucket.

The deployed bucket is:

```text
tkt-mrittika-frontend-55a981101ab488d8fb8a3ac629
```

## API Gateway

The frontend is served through the API Gateway deployment:

```text
https://e36nupge9h.execute-api.ap-southeast-2.amazonaws.com/prod
```

The frontend API base path was configured as:

```javascript
const API_BASE = "/prod/api";
```

The application uses this base path for ticket operations.

## Frontend API Calls

Ticket retrieval:

```javascript
fetch(`${API_BASE}/tickets`)
```

Ticket creation:

```javascript
fetch(`${API_BASE}/tickets`, {
  method: "POST",
  ...
})
```

This allows the static frontend to communicate with the deployed TicketDesk API.

## Initial Problem

The frontend initially loaded but could not retrieve the ticket list.

The browser showed an error indicating that tickets could not be loaded.

The problem was traced to the API path being used by the deployed frontend.

## API Gateway Path Test

Testing the API Gateway root URL directly produced:

```json
{
  "message": "Missing Authentication Token"
}
```

This was used as a route/path diagnostic rather than an application authentication failure.

The deployed API routes were available below:

```text
/prod/api/
```

## Fix

The frontend JavaScript was corrected to use:

```javascript
const API_BASE = "/prod/api";
```

The updated `app.js` was then uploaded to the frontend S3 bucket.

After the update, the frontend successfully loaded the existing tickets.

## End-to-End Ticket Test

A new ticket was created through the browser:

```text
Title: M4 final test
Description: Testing TicketDesk end-to-end frontend integration
Priority: HIGH
Status: OPEN
```

The browser displayed:

```text
Ticket created successfully.
```

The new ticket appeared alongside the persisted M3 ticket.

## Hard Refresh Validation

A hard refresh was performed after ticket creation.

The previously created ticket remained visible.

This confirmed that the frontend was retrieving ticket data from the deployed backend/database rather than relying on browser-only state.

## Final Frontend Result

The deployed frontend successfully supports:

- Loading tickets
- Creating tickets
- Reading persisted tickets
- Refreshing the application without losing ticket data

## Troubleshooting Notes

### Frontend loaded but tickets were missing

The static frontend itself was reachable, but its JavaScript was using the wrong API path.

The deployed API Gateway stage required:

```text
/prod/api
```

Updating `API_BASE` resolved the problem.

### API Gateway root URL

The API Gateway root:

```text
/prod
```

is not the ticket API endpoint itself.

The ticket routes are under:

```text
/prod/api
```

## M4 Result

The TicketDesk frontend was successfully deployed and integrated with the backend using S3 and API Gateway.

Verified components:

- S3 frontend bucket
- API Gateway
- `index.html`
- `styles.css`
- `app.js`
- `/prod/api/tickets` integration
- Browser ticket creation
- Persisted ticket retrieval
- Hard-refresh persistence

**M4: Complete - Alternative S3/API Gateway implementation**

# M5 - Serverless Attachments

## Status

**Completed**

TicketDesk was extended with an end-to-end attachment workflow using presigned S3 uploads and Lambda thumbnail generation.

The browser uploads the attachment directly to S3 using a presigned URL. An S3 upload event triggers the thumbnail Lambda, which writes the generated thumbnail to a separate S3 prefix.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## ECR

The M5 API image was built and pushed to Amazon ECR.

### Repository

```text
ticketdesk
```

### M5 image

```text
243112136699.dkr.ecr.ap-southeast-2.amazonaws.com/ticketdesk:m5-20260818
```

### Image digest

```text
sha256:29ffe5aeb0e3d9124cbe218ba759a94f1e114a12604cc6f04162314c94433a84
```

The image was verified in ECR and deployed to ECS.

## ECS

### Cluster

```text
tkt-mrittika-tf-cluster
```

### Service

```text
tkt-mrittika-tf-service
```

### Task definition

The service was updated to task definition revision:

```text
9
```

The running ECS task was verified with:

```text
image: .../ticketdesk:m5-20260818
lastStatus: RUNNING
```

The ECS service reported:

```text
desired: 1
running: 1
status: ACTIVE
```

## Attachment S3 Bucket

Attachments are stored in the dedicated S3 bucket:

```text
tkt-mrittika-attachments-885d44fb508006c9315bf84cb1
```

Original uploads use the prefix:

```text
originals/tickets/<ticket-id>/
```

Thumbnails use a separate prefix:

```text
thumbnails/tickets/<ticket-id>/
```

## Frontend Attachment Control

The frontend includes:

```html
<label for="attachment">Screenshot (optional)</label>
<input id="attachment" name="attachment" type="file" accept="image/*">
```

This provides the browser file picker for ticket attachments.

## Presigned Upload

When a file is selected, the frontend requests a presigned upload URL from:

```text
POST /prod/api/tickets/{ticket_id}/attachments/presigned-url
```

The request includes:

```text
filename
content_type
```

The browser then uploads the file directly to the returned S3 URL using:

```text
PUT
```

with the file's content type.

The API therefore does not receive the attachment bytes.

## Thumbnail Generation

After the original object is uploaded to S3, the S3 event triggers the thumbnail Lambda.

The Lambda processes the uploaded image and writes the thumbnail under the separate thumbnail prefix.

The frontend then polls the thumbnail endpoint until the thumbnail becomes available:

```text
GET /prod/api/tickets/{ticket_id}/attachments/thumbnail-url
```

Once the thumbnail is ready, the API returns the thumbnail URL to the frontend.

## M5 End-to-End Test

A test attachment was uploaded through the browser.

The frontend reported:

```text
Ticket created and thumbnail generated. View thumbnail
```

The **View thumbnail** link opened the generated S3 thumbnail successfully.

A second test using an actual visible image also successfully displayed the generated thumbnail in the browser.

## Validation

The following were verified:

- M5 Docker image built successfully.
- Image pushed to ECR.
- ECR image digest verified.
- ECS service updated to task definition revision 9.
- Running ECS task uses `ticketdesk:m5-20260818`.
- ECS task status is `RUNNING`.
- Attachment file picker appears in the frontend.
- Ticket creation succeeds with an attachment selected.
- Presigned S3 upload succeeds.
- S3 stores the original attachment.
- S3 event triggers thumbnail processing.
- Thumbnail is generated.
- Thumbnail URL is returned to the frontend.
- Generated thumbnail opens successfully in the browser.

## Troubleshooting Notes

### Missing attachment option

The frontend initially did not display the attachment control because the deployed S3 `app.js` was older than the local version.

The local frontend contained the attachment implementation, including:

```javascript
function ensureAttachmentInput()
```

and the file input:

```html
<input id="attachment" name="attachment" type="file" accept="image/*">
```

The updated `app.js` was uploaded to the frontend S3 bucket.

After refreshing the deployed frontend, the attachment picker appeared.

### `Missing Authentication Token`

Testing the API Gateway root path:

```text
/prod
```

returned:

```json
{
  "message": "Missing Authentication Token"
}
```

The actual API routes are under:

```text
/prod/api
```

### Empty thumbnail test

An initial test used a 1x1 PNG containing essentially no visible content.

The thumbnail URL opened successfully, but there was almost nothing visible in the image.

A later test used an actual visible image and confirmed that the generated thumbnail displayed correctly.

## M5 Architecture

```text
Browser
   |
   | Create ticket
   v
API Gateway
   |
   | /prod/api
   v
Application Load Balancer
   |
   v
ECS Fargate
   |
   +---------------------> RDS PostgreSQL
   |
   | Presigned URL
   v
S3 Attachments Bucket
   |
   | S3 ObjectCreated event
   v
Lambda Thumbnail Function
   |
   v
S3 thumbnails/ prefix
   |
   | Thumbnail URL
   v
Browser
```

## M5 Result

The TicketDesk serverless attachment workflow is operational.

Verified components:

- ECS M5 container image
- ECR
- Presigned S3 upload
- Attachment S3 bucket
- S3 upload event
- Lambda thumbnail generation
- Thumbnail S3 prefix
- Frontend attachment control
- Thumbnail retrieval
- Browser thumbnail display

**M5: Complete**

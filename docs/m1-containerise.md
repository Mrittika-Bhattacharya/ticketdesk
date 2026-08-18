# M1 - Containerise

## Status

**Completed**

The TicketDesk FastAPI application was containerised using a multi-stage Docker build and prepared for deployment to Amazon ECR with a traceable Git commit SHA.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## Container Registry

Amazon ECR is used to store the TicketDesk API container image.

- Repository: `ticketdesk`
- Image tag: `51fdc92`
- Image tag strategy: Git commit SHA rather than `latest`

The recorded Git commit was:

```text
51fdc92
```

The container image was successfully built from the TicketDesk project and prepared for ECR deployment.

## Docker Build

The application was built using:

```cmd
docker build -t ticketdesk-api:51fdc92 .
```

The build completed successfully.

The build output showed a multi-stage build using:

```text
python:3.10-slim
```

The builder stage installed the Python dependencies, while the final stage copied the required runtime files.

## Container Structure

The final container contains the TicketDesk API application and its runtime dependencies.

The Docker build was structured so that build-time dependency installation is performed separately from the final runtime image.

The application runs as the TicketDesk API rather than as a local development process.

## Validation

The following were verified:

- Docker build completed successfully.
- The image was tagged using the Git commit SHA.
- The project changes were committed to Git.
- The image was prepared for ECR deployment.

The retained M1 evidence confirms the successful build and the traceable `51fdc92` image tag.

## Troubleshooting Notes

### Avoiding `latest`

The milestone requires traceable image versions rather than a mutable `latest` tag.

The Git commit SHA was therefore used:

```text
51fdc92
```

This makes it possible to associate the deployed container with a specific repository revision.

## M1 Result

The TicketDesk API was successfully containerised and prepared as a traceable ECR image.

Verified components:

- Multi-stage Docker build
- Python 3.10 slim runtime
- Git SHA image tagging
- Successful Docker build
- ECR-ready TicketDesk API image

**M1: Complete**

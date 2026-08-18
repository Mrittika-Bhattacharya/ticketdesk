# M3 - Database and Secrets

## Status

**Completed**

TicketDesk was connected to Amazon RDS PostgreSQL for persistent storage, with database configuration managed through AWS services rather than application source code.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## RDS PostgreSQL

The application uses Amazon RDS PostgreSQL.

### Database

```text
Database name: ticketdesk
Username: ticketdesk
Instance class: db.t4g.micro
Port: 5432
```

The RDS instance is deployed using the private subnet infrastructure created by Terraform.

The database endpoint is managed as an infrastructure output rather than hardcoded into the application.

## Database Configuration

Terraform manages the database-related resources, including:

- RDS PostgreSQL instance
- DB subnet group
- Private subnets
- RDS security group
- Database configuration

The database is not intended to be publicly accessible.

## Secrets Manager

The RDS master credentials are managed through AWS Secrets Manager.

Terraform exposes the Secrets Manager ARN as:

```text
rds_master_secret_arn
```

The database password is not stored in the application repository.

## Parameter Store

Application database configuration is stored using AWS Systems Manager Parameter Store.

The deployed parameters include:

```text
/ticketdesk/db/name
/ticketdesk/db/user
/ticketdesk/db/host
/ticketdesk/db/port
```

This separates environment configuration from application source code.

## IAM

The ECS task execution/application roles are configured to allow the running application to obtain the required AWS-managed configuration and secrets.

The application therefore does not need database credentials embedded in the repository.

## Schema Migration

The application image used for the deployment includes the database migration/startup handling required to create and use the TicketDesk database schema.

The migration-enabled application image was recorded in the project history before the frontend and attachment milestones.

## Persistence Test

A test ticket was created and stored in the RDS-backed application:

```text
Title: M3 persistence test
Description: Testing TicketDesk with RDS
Priority: medium
Status: open
```

The deployed API returned the persisted ticket through:

```text
https://e36nupge9h.execute-api.ap-southeast-2.amazonaws.com/prod/api/tickets
```

The API returned the stored ticket successfully.

## Validation

The following were verified:

- RDS PostgreSQL instance exists.
- RDS is connected to the private network.
- Database configuration is supplied through AWS-managed configuration.
- Database credentials are stored in Secrets Manager.
- Application configuration is stored in Parameter Store.
- Ticket data is persisted in PostgreSQL.
- The persisted ticket can be retrieved through the deployed API.

The ticket also remained available during the later frontend tests, confirming that the application was reading persistent backend data rather than browser-only state.

## Troubleshooting Notes

### Database readiness

The application required reliable database availability during deployment and startup.

The deployment was adjusted so the application could work against the RDS-backed database rather than relying on a local PostgreSQL container.

### Configuration separation

Database connection information was separated from the application source code using Parameter Store and Secrets Manager.

This avoids putting the database password in configuration files or Git.

## M3 Result

TicketDesk successfully moved from transient/local database testing to persistent Amazon RDS PostgreSQL storage.

Verified components:

- RDS PostgreSQL
- Private database networking
- DB subnet group
- Secrets Manager
- Parameter Store
- ECS access to database configuration
- Persistent ticket storage
- API retrieval of persisted tickets

**M3: Complete**

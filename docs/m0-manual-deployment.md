# M0 - Manual AWS Deployment

## Status

**Completed**

The TicketDesk API was successfully deployed manually to AWS ECS using AWS Fargate and exposed through an Application Load Balancer.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## Container Registry

Amazon ECR is used to store the TicketDesk API Docker image.

- Repository: `ticketdesk`
- API container port: `8000`

## ECS

### Cluster

- Cluster: `tkt-mrittika-cluster`

### Task Definition

- Task definition family: `tkt-mrittika-task`
- Working revision: `3`
- Launch type: AWS Fargate
- CPU: `0.5 vCPU`
- Memory: `1 GiB`

The task contains two containers:

1. `ticketdesk-api`
2. `postgres`

### TicketDesk API Container

- Application: FastAPI
- Server: Uvicorn
- Container port: `8000`
- Uvicorn listens on `0.0.0.0:8000`

### PostgreSQL Container

- Image: `postgres:17`
- Database: `ticketdesk`
- User: `ticketdesk`
- Port: `5432`

A PostgreSQL health check is configured so the API can wait for the database to become healthy before starting.

## ECS Service

- Service: `tkt-mrittika-service`
- Desired tasks: `1`
- Capacity provider: `FARGATE`

The service maintains the required running task automatically.

A manually launched standalone task used during initial testing was stopped after the ECS service was verified.

---

## Application Load Balancer

- Load balancer: `tkt-mrittika-alb`
- Scheme: Internet-facing
- Listener: HTTP port `80`

The listener forwards requests to:

- Target group: `tkt-mrittika-api-tg`
- Target type: IP
- Protocol: HTTP
- Port: `8000`
- Health check path: `/health`

The ECS service task successfully registered with the target group and reached the `Healthy` state.

## Security Groups

### ALB Security Group

The Application Load Balancer accepts public HTTP traffic.

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
```

### ECS Security Group

The ECS security group allows TCP port `8000` from the **ALB security group**, rather than from `0.0.0.0/0`.

Therefore, clients access the API through the ALB rather than connecting directly to the application container.

---

## Validation

Swagger UI was successfully accessed through the Application Load Balancer:

```text
http://tkt-mrittika-alb-604463946.ap-southeast-2.elb.amazonaws.com/docs
```

The health endpoint was also successfully tested:

```text
http://tkt-mrittika-alb-604463946.ap-southeast-2.elb.amazonaws.com/health
```

Expected response:

```json
{
  "status": "healthy"
}
```

The target group also reported the ECS service task as:

```text
Healthy
```

---

## Troubleshooting Notes

Several issues were identified during the manual deployment.

### API started before PostgreSQL was ready

The API initially attempted to start before PostgreSQL was ready to accept connections.

This was addressed by adding a PostgreSQL health check and configuring the API container to depend on PostgreSQL reaching the healthy state.

### PostgreSQL database-name configuration

A database-name configuration issue was identified during deployment.

The final PostgreSQL database name is:

```text
ticketdesk
```

### Direct public-IP timeout

Direct access to the Fargate task on port `8000` initially timed out because of the security-group configuration.

Temporary public access to port `8000` was used during troubleshooting.

After the Application Load Balancer was configured and verified, the ECS security group was hardened so that port `8000` accepts traffic from the ALB security group only.

---

## Final M0 Architecture

```text
Internet
   |
   | HTTP :80
   v
Application Load Balancer
tkt-mrittika-alb
   |
   | HTTP :8000
   v
Target Group
tkt-mrittika-api-tg
   |
   v
ECS Service
tkt-mrittika-service
   |
   v
Fargate Task
   |
   +----------------------+
   |                      |
   v                      v
ticketdesk-api          postgres
:8000                   :5432
   |                      ^
   +----------------------+
       database access
```

## M0 Result

The manual AWS deployment is operational.

Verified components:

- ECR container image
- ECS Fargate task
- PostgreSQL container
- ECS service
- Application Load Balancer
- Target group health checks
- ALB-to-ECS security-group routing
- FastAPI Swagger UI
- `/health` endpoint

**M0: Complete**
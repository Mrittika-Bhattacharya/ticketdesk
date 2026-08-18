# M2 - Infrastructure as Code

## Status

**Completed**

The manual AWS deployment was reproduced using Terraform. The infrastructure includes the VPC, public and private subnets, networking, security groups, Application Load Balancer, target group, ECS cluster, ECS task definition and ECS service.

---

## AWS Region

- Region: Asia Pacific (Sydney)
- Region code: `ap-southeast-2`

## Terraform

Terraform is used to define the AWS infrastructure.

The project contains Terraform configuration for:

- Networking
- Security groups
- Application Load Balancer
- ECS cluster
- ECS task definition
- ECS service
- Supporting IAM resources
- RDS
- S3
- API Gateway
- Parameter Store
- Secrets Manager

The main Terraform project is stored under:

```text
terraform/
```

## Project Configuration

The Terraform project uses:

```text
project_name = tkt-mrittika
aws_region   = ap-southeast-2
```

The VPC CIDR is:

```text
10.20.0.0/16
```

## Network

Two public subnets and two private subnets are defined.

### Public subnets

```text
10.20.10.0/24
10.20.20.0/24
```

### Private subnets

```text
10.20.110.0/24
10.20.120.0/24
```

The subnets span:

```text
ap-southeast-2a
ap-southeast-2b
```

The Application Load Balancer is placed in the public subnets while the ECS application runs in private subnets.

## ECS

### Cluster

```text
tkt-mrittika-tf-cluster
```

### Service

```text
tkt-mrittika-tf-service
```

### Task Definition

```text
tkt-mrittika-tf-task
```

The ECS service runs the TicketDesk API using AWS Fargate.

## Application Load Balancer

- Load balancer: `tkt-mrittika-tf-alb`
- Listener: HTTP port `80`
- Target group: `tkt-mrittika-tf-api-tg`
- Target type: IP
- Health check path: `/health`

The ALB provides the public entry point to the ECS API.

## Security Groups

The infrastructure defines separate security groups for:

- ALB
- ECS
- RDS

The ECS application traffic is routed through the ALB rather than exposing the application directly to the internet.

## Terraform Validation

Terraform configuration was validated successfully:

```cmd
terraform validate
```

Result:

```text
Success! The configuration is valid.
```

Terraform was then used to apply the infrastructure.

The retained Terraform state and outputs show the deployed VPC, public and private subnets, ECS cluster/service, ALB, target group, RDS and supporting AWS resources.

## Important Outputs

The deployed infrastructure produced outputs including:

```text
alb_dns_name
ecs_cluster_name
ecs_service_name
target_group_arn
vpc_id
private_subnet_ids
public_subnet_ids
rds_endpoint
```

The final ALB DNS name is:

```text
tkt-mrittika-tf-alb-1714382545.ap-southeast-2.elb.amazonaws.com
```

## Validation

The infrastructure was validated through:

- Terraform validation
- Terraform plan/apply
- ECS service state
- ALB health checks
- Target group health
- API access through the ALB

The application health endpoint returned:

```json
{
  "status": "healthy"
}
```

## Troubleshooting Notes

### Replacing the manually deployed infrastructure

M2 moved the deployment from manually created AWS resources to infrastructure managed through Terraform.

This made the infrastructure configuration reproducible and allowed later milestones to add RDS, S3, API Gateway and Lambda through the same Terraform project.

## M2 Result

The TicketDesk AWS infrastructure was successfully defined and deployed through Terraform.

Verified components:

- VPC
- Two public subnets
- Two private subnets
- Multi-AZ networking
- Security groups
- Application Load Balancer
- Target group
- ECS Fargate cluster
- ECS task definition
- ECS service
- Supporting IAM resources

**M2: Complete**

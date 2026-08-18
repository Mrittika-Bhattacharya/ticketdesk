output "vpc_id" {
  description = "Terraform TicketDesk VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = aws_security_group.ecs.id
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.api.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.main.name
}

output "swagger_url" {
  description = "TicketDesk Swagger URL"
  value       = "http://${aws_lb.main.dns_name}/docs"
}

output "health_url" {
  description = "TicketDesk health-check URL"
  value       = "http://${aws_lb.main.dns_name}/health"
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.postgres.port
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN for the RDS master credential"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "frontend_bucket_name" {
  description = "Private S3 bucket containing the TicketDesk frontend"
  value       = aws_s3_bucket.frontend.bucket
}

output "api_gateway_url" {
  description = "TicketDesk API Gateway URL"
  value       = aws_api_gateway_stage.default.invoke_url
}
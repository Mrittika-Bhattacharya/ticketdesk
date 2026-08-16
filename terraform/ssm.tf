resource "aws_ssm_parameter" "db_host" {
  name        = "/ticketdesk/db/host"
  description = "TicketDesk RDS hostname"
  type        = "String"
  value       = aws_db_instance.postgres.address

  tags = {
    Name = "${var.project_name}-db-host"
  }
}

resource "aws_ssm_parameter" "db_port" {
  name        = "/ticketdesk/db/port"
  description = "TicketDesk RDS port"
  type        = "String"
  value       = tostring(aws_db_instance.postgres.port)

  tags = {
    Name = "${var.project_name}-db-port"
  }
}

resource "aws_ssm_parameter" "db_name" {
  name        = "/ticketdesk/db/name"
  description = "TicketDesk database name"
  type        = "String"
  value       = var.db_name

  tags = {
    Name = "${var.project_name}-db-name"
  }
}

resource "aws_ssm_parameter" "db_user" {
  name        = "/ticketdesk/db/user"
  description = "TicketDesk database username"
  type        = "String"
  value       = var.db_username

  tags = {
    Name = "${var.project_name}-db-user"
  }
}
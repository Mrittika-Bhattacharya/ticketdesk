resource "aws_security_group" "rds" {
  name        = "${var.project_name}-tf-rds-sg"
  description = "Security group for TicketDesk RDS PostgreSQL"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow PostgreSQL only from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-tf-rds-sg"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-tf-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  tags = {
    Name = "${var.project_name}-tf-db-subnet-group"
  }
}
resource "aws_db_instance" "postgres" {
  identifier = "${var.project_name}-tf-postgres"

  engine         = "postgres"
  engine_version = "17"

  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  multi_az            = false

  backup_retention_period = 1

  tags = {
    Name = "${var.project_name}-tf-postgres"
  }
}
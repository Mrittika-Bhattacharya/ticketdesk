resource "aws_security_group" "alb" {
  name        = "${var.project_name}-tf-alb-sg"
  description = "Security group for TicketDesk Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-tf-alb-sg"
  }
}


resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-tf-ecs-sg"
  description = "Security group for TicketDesk ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow FastAPI traffic only from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow outbound traffic through NAT Gateway"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-tf-ecs-sg"
  }
}
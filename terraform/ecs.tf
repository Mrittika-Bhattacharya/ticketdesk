resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-tf-cluster"

  tags = {
    Name = "${var.project_name}-tf-cluster"
  }
}


resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-tf-task"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-tf-logs"
  }
}


resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-tf-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-tf-ecs-execution-role"
  }
}


resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_iam_role_policy" "ecs_secrets" {
  name = "${var.project_name}-tf-ecs-secrets"

  role = aws_iam_role.ecs_task_execution.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          aws_db_instance.postgres.master_user_secret[0].secret_arn
        ]
      }
    ]
  })
}


resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-tf-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "512"
  memory = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "ticketdesk-api"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = aws_db_instance.postgres.address
        },
        {
          name  = "DB_PORT"
          value = tostring(aws_db_instance.postgres.port)
        },
        {
          name  = "DB_NAME"
          value = var.db_name
        },
        {
          name  = "DB_USER"
          value = var.db_username
        }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "${aws_db_instance.postgres.master_user_secret[0].secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-tf-task"
  }
}


resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-tf-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]

    security_groups = [
      aws_security_group.ecs.id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "ticketdesk-api"
    container_port   = 8000
  }

  depends_on = [
    aws_lb_listener.http,
    aws_nat_gateway.main,
    aws_db_instance.postgres,
    aws_iam_role_policy.ecs_secrets
  ]

  tags = {
    Name = "${var.project_name}-tf-service"
  }
}
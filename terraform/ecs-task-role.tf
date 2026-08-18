resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-tf-ecs-task-role"

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
    Name = "${var.project_name}-tf-ecs-task-role"
  }
}

resource "aws_iam_role_policy" "ecs_task_s3" {
  name = "${var.project_name}-tf-ecs-task-s3"

  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.attachments.arn}/*"
      }
    ]
  })
}
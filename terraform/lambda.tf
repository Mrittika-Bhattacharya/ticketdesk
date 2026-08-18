resource "aws_iam_role" "lambda_thumbnail" {
  name = "${var.project_name}-tf-thumbnail-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-tf-thumbnail-lambda-role"
  }
}


resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_thumbnail.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_iam_role_policy" "lambda_s3" {
  name = "${var.project_name}-tf-thumbnail-lambda-s3"

  role = aws_iam_role.lambda_thumbnail.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject"
        ]

        Resource = "${aws_s3_bucket.attachments.arn}/originals/*"
      },
      {
        Effect = "Allow"

        Action = [
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.attachments.arn}/thumbnails/*"
      }
    ]
  })
}


resource "aws_lambda_function" "thumbnail" {
  function_name = "${var.project_name}-tf-thumbnail"

  role    = aws_iam_role.lambda_thumbnail.arn
  handler = "lambda_function.lambda_handler"
  runtime = "python3.12"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  timeout     = 30
  memory_size = 512

  tags = {
    Name = "${var.project_name}-tf-thumbnail"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic_execution,
    aws_iam_role_policy.lambda_s3
  ]
}


resource "aws_lambda_permission" "allow_s3" {
  statement_id = "AllowS3Invoke"

  action = "lambda:InvokeFunction"

  function_name = aws_lambda_function.thumbnail.function_name

  principal = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.attachments.arn
}


resource "aws_s3_bucket_notification" "attachments" {
  bucket = aws_s3_bucket.attachments.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.thumbnail.arn

    events = [
      "s3:ObjectCreated:*"
    ]

    filter_prefix = "originals/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}
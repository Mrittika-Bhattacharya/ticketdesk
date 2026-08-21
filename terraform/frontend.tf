resource "aws_s3_bucket" "frontend" {
  bucket_prefix = "${var.project_name}-frontend-"

  tags = {
    Name = "${var.project_name}-frontend"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload frontend files to S3

resource "aws_s3_object" "frontend_index" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "index.html"
  source       = "${path.module}/../frontend/index.html"
  etag         = filemd5("${path.module}/../frontend/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "frontend_styles" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "styles.css"
  source       = "${path.module}/../frontend/styles.css"
  etag         = filemd5("${path.module}/../frontend/styles.css")
  content_type = "text/css"
}

resource "aws_s3_object" "frontend_app" {
  bucket       = aws_s3_bucket.frontend.id
  key          = "app.js"
  source       = "${path.module}/../frontend/app.js"
  etag         = filemd5("${path.module}/../frontend/app.js")
  content_type = "application/javascript"
}
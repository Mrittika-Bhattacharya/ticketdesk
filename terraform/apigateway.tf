# ============================================================
# API GATEWAY REST API
# ============================================================

resource "aws_api_gateway_rest_api" "ticketdesk" {
  name        = "${var.project_name}-api"
  description = "TicketDesk frontend and API gateway"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}


# ============================================================
# API GATEWAY -> S3 IAM ROLE
# ============================================================

resource "aws_iam_role" "apigateway_s3" {
  name = "${var.project_name}-apigateway-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "apigateway.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-apigateway-s3-role"
  }
}


resource "aws_iam_role_policy" "apigateway_s3" {
  name = "${var.project_name}-apigateway-s3-policy"
  role = aws_iam_role.apigateway_s3.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          aws_s3_bucket.frontend.arn,
          "${aws_s3_bucket.frontend.arn}/*"
        ]
      }
    ]
  })
}


# ============================================================
# FRONTEND - /index.html
# ============================================================

resource "aws_api_gateway_resource" "index_html" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  parent_id   = aws_api_gateway_rest_api.ticketdesk.root_resource_id
  path_part   = "index.html"
}


resource "aws_api_gateway_method" "index_html" {
  rest_api_id   = aws_api_gateway_rest_api.ticketdesk.id
  resource_id   = aws_api_gateway_resource.index_html.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "index_html" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.index_html.id
  http_method = aws_api_gateway_method.index_html.http_method

  type = "AWS"

  integration_http_method = "GET"

  uri = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.frontend.bucket}/index.html"

  credentials = aws_iam_role.apigateway_s3.arn
}


resource "aws_api_gateway_method_response" "index_html" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.index_html.id
  http_method = aws_api_gateway_method.index_html.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = false
  }
}


resource "aws_api_gateway_integration_response" "index_html" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.index_html.id
  http_method = aws_api_gateway_method.index_html.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }

  depends_on = [
    aws_api_gateway_integration.index_html
  ]
}


# ============================================================
# FRONTEND - /styles.css
# ============================================================

resource "aws_api_gateway_resource" "styles" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  parent_id   = aws_api_gateway_rest_api.ticketdesk.root_resource_id
  path_part   = "styles.css"
}


resource "aws_api_gateway_method" "styles" {
  rest_api_id   = aws_api_gateway_rest_api.ticketdesk.id
  resource_id   = aws_api_gateway_resource.styles.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "styles" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.styles.id
  http_method = aws_api_gateway_method.styles.http_method

  type = "AWS"

  integration_http_method = "GET"

  uri = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.frontend.bucket}/styles.css"

  credentials = aws_iam_role.apigateway_s3.arn
}


resource "aws_api_gateway_method_response" "styles" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.styles.id
  http_method = aws_api_gateway_method.styles.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = false
  }
}


resource "aws_api_gateway_integration_response" "styles" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.styles.id
  http_method = aws_api_gateway_method.styles.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }

  depends_on = [
    aws_api_gateway_integration.styles
  ]
}


# ============================================================
# FRONTEND - /app.js
# ============================================================

resource "aws_api_gateway_resource" "app" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  parent_id   = aws_api_gateway_rest_api.ticketdesk.root_resource_id
  path_part   = "app.js"
}


resource "aws_api_gateway_method" "app" {
  rest_api_id   = aws_api_gateway_rest_api.ticketdesk.id
  resource_id   = aws_api_gateway_resource.app.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "app" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.app.id
  http_method = aws_api_gateway_method.app.http_method

  type = "AWS"

  integration_http_method = "GET"

  uri = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.frontend.bucket}/app.js"

  credentials = aws_iam_role.apigateway_s3.arn
}


resource "aws_api_gateway_method_response" "app" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.app.id
  http_method = aws_api_gateway_method.app.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = false
  }
}


resource "aws_api_gateway_integration_response" "app" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.app.id
  http_method = aws_api_gateway_method.app.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = "integration.response.header.Content-Type"
  }

  depends_on = [
    aws_api_gateway_integration.app
  ]
}


# ============================================================
# API - /api/{proxy+} -> ALB
# ============================================================

resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  parent_id   = aws_api_gateway_rest_api.ticketdesk.root_resource_id
  path_part   = "api"
}


resource "aws_api_gateway_resource" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "{proxy+}"
}


resource "aws_api_gateway_method" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.api_proxy.id

  http_method   = "ANY"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.proxy" = true
  }
}


resource "aws_api_gateway_integration" "api_proxy" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id
  resource_id = aws_api_gateway_resource.api_proxy.id
  http_method = aws_api_gateway_method.api_proxy.http_method

  type = "HTTP_PROXY"

  integration_http_method = "ANY"

  uri = "http://${aws_lb.main.dns_name}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


# ============================================================
# DEPLOYMENT
# ============================================================

resource "aws_api_gateway_deployment" "ticketdesk" {
  rest_api_id = aws_api_gateway_rest_api.ticketdesk.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.index_html.id,
      aws_api_gateway_method.index_html.id,
      aws_api_gateway_integration.index_html.id,

      aws_api_gateway_resource.styles.id,
      aws_api_gateway_method.styles.id,
      aws_api_gateway_integration.styles.id,
      aws_api_gateway_method_response.styles.id,
      aws_api_gateway_integration_response.styles.id,

      aws_api_gateway_resource.app.id,
      aws_api_gateway_method.app.id,
      aws_api_gateway_integration.app.id,
      aws_api_gateway_method_response.app.id,
      aws_api_gateway_integration_response.app.id,

      aws_api_gateway_resource.api.id,
      aws_api_gateway_resource.api_proxy.id,
      aws_api_gateway_method.api_proxy.id,
      aws_api_gateway_integration.api_proxy.id
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.index_html,
    aws_api_gateway_integration.styles,
    aws_api_gateway_integration.app,
    aws_api_gateway_integration.api_proxy,
    aws_api_gateway_integration_response.index_html,
    aws_api_gateway_integration_response.styles,
    aws_api_gateway_integration_response.app
  ]

  lifecycle {
    create_before_destroy = true
  }
}


# ============================================================
# STAGE
# ============================================================

resource "aws_api_gateway_stage" "default" {
  rest_api_id   = aws_api_gateway_rest_api.ticketdesk.id
  deployment_id = aws_api_gateway_deployment.ticketdesk.id
  stage_name    = "prod"

  tags = {
    Name = "${var.project_name}-api-prod"
  }
}
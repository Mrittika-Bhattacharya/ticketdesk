# ============================================================
# M7 - OBSERVABILITY
# CloudWatch Dashboard + SNS Notifications + 3 Alarms
# ============================================================


# ============================================================
# SNS TOPIC
# ============================================================

resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-alerts"

  tags = {
    Name = "${var.project_name}-alerts"
  }
}


# ============================================================
# SNS EMAIL SUBSCRIPTION
# ============================================================

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}


# ============================================================
# CLOUDWATCH DASHBOARD
# ============================================================

resource "aws_cloudwatch_dashboard" "ticketdesk" {
  dashboard_name = "${var.project_name}-observability"

  dashboard_body = jsonencode({
    widgets = [

      # --------------------------------------------------------
      # REQUEST COUNT
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "TicketDesk Request Count"
          region = var.aws_region

          stat   = "Sum"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.main.arn_suffix
            ]
          ]

          view  = "timeSeries"
          stack = false
        }
      },


      # --------------------------------------------------------
      # ERROR RATE
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "TicketDesk 5xx Error Rate (%)"
          region = var.aws_region

          view   = "timeSeries"
          stat   = "Sum"
          period = 300

          metrics = [
            [
              {
                expression = "IF(m1>0,100*m2/m1,0)"
                label      = "5xx Error Rate"
                id         = "e1"
              }
            ],
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              aws_lb.main.arn_suffix,
              {
                id = "m1"
              }
            ],
            [
              "AWS/ApplicationELB",
              "HTTPCode_Target_5XX_Count",
              "LoadBalancer",
              aws_lb.main.arn_suffix,
              {
                id = "m2"
              }
            ]
          ]

          yAxis = {
            left = {
              label = "Percent"
              min   = 0
            }
          }
        }
      },


      # --------------------------------------------------------
      # RESPONSE TIME
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "TicketDesk Response Time"
          region = var.aws_region

          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              aws_lb.main.arn_suffix
            ]
          ]

          view = "timeSeries"

          yAxis = {
            left = {
              label = "Seconds"
              min   = 0
            }
          }
        }
      },


      # --------------------------------------------------------
      # ECS CPU
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title  = "ECS CPU Utilization"
          region = var.aws_region

          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ECS",
              "CPUUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.main.name
            ]
          ]

          view = "timeSeries"

          yAxis = {
            left = {
              label = "Percent"
              min   = 0
              max   = 100
            }
          }
        }
      },


      # --------------------------------------------------------
      # ECS MEMORY
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "ECS Memory Utilization"
          region = var.aws_region

          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/ECS",
              "MemoryUtilization",
              "ClusterName",
              aws_ecs_cluster.main.name,
              "ServiceName",
              aws_ecs_service.main.name
            ]
          ]

          view = "timeSeries"

          yAxis = {
            left = {
              label = "Percent"
              min   = 0
              max   = 100
            }
          }
        }
      },


      # --------------------------------------------------------
      # RDS DATABASE CONNECTIONS
      # --------------------------------------------------------

      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title  = "RDS Database Connections"
          region = var.aws_region

          stat   = "Average"
          period = 300

          metrics = [
            [
              "AWS/RDS",
              "DatabaseConnections",
              "DBInstanceIdentifier",
              aws_db_instance.postgres.identifier
            ]
          ]

          view = "timeSeries"

          yAxis = {
            left = {
              label = "Connections"
              min   = 0
            }
          }
        }
      }

    ]
  })
}


# ============================================================
# ALARM 1 - API 5xx ERRORS
# ============================================================

resource "aws_cloudwatch_metric_alarm" "api_5xx" {
  alarm_name = "${var.project_name}-api-5xx-errors"

  alarm_description = "TicketDesk API is returning 5xx errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_Target_5XX_Count"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-api-5xx-alarm"
  }
}


# ============================================================
# ALARM 2 - UNHEALTHY TARGETS
# ============================================================

resource "aws_cloudwatch_metric_alarm" "unhealthy_targets" {
  alarm_name = "${var.project_name}-unhealthy-targets"

  alarm_description = "TicketDesk ECS target is unhealthy"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.api.arn_suffix
  }

  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-unhealthy-targets-alarm"
  }
}


# ============================================================
# ALARM 3 - HIGH DATABASE CPU
# ============================================================

resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  alarm_name = "${var.project_name}-database-high-cpu"

  alarm_description = "TicketDesk RDS PostgreSQL CPU utilization is high"

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  statistic           = "Average"
  period              = 300
  evaluation_periods  = 2
  datapoints_to_alarm = 2

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 80

  treat_missing_data = "notBreaching"

  alarm_actions = [
    aws_sns_topic.alerts.arn
  ]

  tags = {
    Name = "${var.project_name}-database-cpu-alarm"
  }
}


# ============================================================
# OUTPUTS
# ============================================================

output "cloudwatch_dashboard_name" {
  description = "TicketDesk CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.ticketdesk.dashboard_name
}

output "sns_alert_topic_arn" {
  description = "SNS topic used for TicketDesk CloudWatch alarms"
  value       = aws_sns_topic.alerts.arn
}

output "api_5xx_alarm_name" {
  description = "TicketDesk API 5xx CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.api_5xx.alarm_name
}

output "unhealthy_targets_alarm_name" {
  description = "TicketDesk unhealthy target CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.unhealthy_targets.alarm_name
}

output "database_cpu_alarm_name" {
  description = "TicketDesk RDS CPU CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.database_cpu.alarm_name
}


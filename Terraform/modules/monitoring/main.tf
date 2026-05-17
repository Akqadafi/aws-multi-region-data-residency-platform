resource "aws_cloudwatch_log_group" "arcanum_log_group01" {
  name              = "/aws/ec2/${var.project_name}-rds-app"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-log-group01"
  })
}

resource "aws_sns_topic" "arcanum_sns_topic01" {
  name = "${var.project_name}-db-incidents"
}

resource "aws_sns_topic_subscription" "arcanum_sns_sub01" {
  topic_arn = aws_sns_topic.arcanum_sns_topic01.arn
  protocol  = "email"
  endpoint  = var.sns_email_endpoint
}

resource "aws_cloudwatch_metric_alarm" "arcanum_db_alarm01" {
  alarm_name          = "${var.project_name}-db-connection-failure"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "DBConnectionErrors"
  namespace           = "Lab/RDSApp"
  period              = 300
  statistic           = "Sum"
  threshold           = 3

  alarm_actions = [aws_sns_topic.arcanum_sns_topic01.arn]

  tags = merge(var.tags, {
    Name = "${var.project_name}-alarm-db-fail"
  })
}

############################################
# Monitoring: ALB 5xx Alarm
############################################

resource "aws_cloudwatch_metric_alarm" "arcanum_alb_5xx_alarm01" {
  alarm_name          = "${var.project_name}-alb-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [aws_sns_topic.arcanum_sns_topic01.arn]
}

############################################
# Dashboard
############################################

resource "aws_cloudwatch_dashboard" "arcanum_dashboard01" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix],
            [".", "HTTPCode_ELB_5XX_Count", ".", "."]
          ]
          period = 60
          stat   = "Sum"
          region = var.aws_region
          title  = "ALB Requests + 5XX"
        }
      }
    ]
  })
}

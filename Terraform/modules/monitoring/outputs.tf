output "arcanum_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for the EC2 app"
  value       = aws_cloudwatch_log_group.arcanum_log_group01.arn
}

output "arcanum_log_group_name" {
  description = "Name of the CloudWatch Log Group for the EC2 app"
  value       = aws_cloudwatch_log_group.arcanum_log_group01.name
}

output "arcanum_sns_topic_arn" {
  description = "ARN of the SNS topic used for alarms"
  value       = aws_sns_topic.arcanum_sns_topic01.arn
}

output "arcanum_dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.arcanum_dashboard01.dashboard_name
}

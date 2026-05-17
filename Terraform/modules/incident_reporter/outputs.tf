output "arcanum_ir_reports_bucket" {
  description = "S3 bucket name where auto-generated incident reports are stored."
  value       = aws_s3_bucket.arcanum_ir_reports_bucket01.bucket
}

output "arcanum_ir_lambda_function_name" {
  description = "Lambda function name for the Bedrock auto incident reporter."
  value       = aws_lambda_function.arcanum_ir_lambda01.function_name
}

output "arcanum_ir_lambda_function_arn" {
  description = "Lambda function ARN for the Bedrock auto incident reporter."
  value       = aws_lambda_function.arcanum_ir_lambda01.arn
}

output "arcanum_ir_report_ready_topic_arn" {
  description = "SNS topic ARN used for 'IR Report Ready' notifications."
  value       = local.arcanum_report_ready_topic_arn
}

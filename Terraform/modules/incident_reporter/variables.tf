variable "project_name" {
  description = "Name prefix used for tagging and resource naming."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "sns_topic_arn" {
  description = "SNS topic ARN that receives CloudWatch alarms."
  type        = string
}

variable "enable_separate_report_ready_topic" {
  description = "If true, create a dedicated SNS topic for 'IR Report Ready' notifications."
  type        = bool
  default     = true
}

variable "report_ready_topic_arn" {
  description = "Optional existing SNS topic ARN for report-ready notifications. If set, module will publish there."
  type        = string
  default     = ""
}

variable "report_ready_email_endpoint" {
  description = "Optional email endpoint subscribed to the report-ready SNS topic."
  type        = string
  default     = ""
}

variable "app_log_group_name" {
  description = "CloudWatch log group name for the application."
  type        = string
}

variable "waf_log_group_name" {
  description = "CloudWatch log group name for WAF logs. Null/empty skips WAF Insights queries."
  type        = string
  default     = null
}

variable "secret_id" {
  description = "Secrets Manager secret ID or ARN for database credentials."
  type        = string
}

variable "ssm_param_path" {
  description = "SSM Parameter Store path prefix for known-good DB config."
  type        = string
  default     = "/lab/db/"
}

variable "bedrock_model_id" {
  description = "Bedrock model ID for report generation."
  type        = string
}

variable "auto_ir_mode" {
  description = "Report mode: fast (15m) or deep (60m)."
  type        = string
  default     = "fast"

  validation {
    condition     = contains(["fast", "deep"], lower(var.auto_ir_mode))
    error_message = "auto_ir_mode must be one of: fast, deep."
  }
}

variable "fast_report_window_minutes" {
  description = "Window in minutes used when auto_ir_mode is fast."
  type        = number
  default     = 15
}

variable "report_prefix" {
  description = "S3 key prefix for generated report artifacts."
  type        = string
  default     = "reports"
}

variable "report_bucket_force_destroy" {
  description = "Allow Terraform to destroy IR reports bucket even when non-empty."
  type        = bool
  default     = false
}

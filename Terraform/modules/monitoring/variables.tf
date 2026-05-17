variable "sns_email_endpoint" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}

variable "alb_arn_suffix" {
  type        = string
  description = "ARN suffix for ALB (for CloudWatch dimensions)"
}


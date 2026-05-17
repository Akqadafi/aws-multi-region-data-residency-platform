variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "alb_sg_id" {
  type        = string
  description = "ALB security group ID (for EC2 ingress from ALB)"
}

variable "my_ip_cidr" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  default     = "arcanum"
  type        = string
}


variable "env" {
  description = "Environment name (e.g., dev, lab, prod). Used in tags if you want it."
  type        = string
  default     = "lab"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-1"
}

variable "enable_waf" {
  description = "Whether to create and attach WAFv2 Web ACL to the ALB."
  type        = bool
  default     = true
}

variable "enable_origin_cloaking" {
  description = "Enable Lab 2 CloudFront origin cloaking pattern"
  type        = bool
}

variable "alb_allow_public_http_https" {
  description = "If true, ALB allows public HTTP/HTTPS ingress (Lab 1). If false, ALB is locked down for CloudFront only (Lab 2)."
  type        = bool
  default     = true
}

variable "alb_arn" {
  type        = string
  description = "ALB ARN (for WAF association)"
  default     = null
}

variable "waf_log_destination" {
  description = "Choose ONE destination per WebACL: cloudwatch | s3 | firehose"
  type        = string
  default     = "cloudwatch"

  validation {
    condition     = contains(["cloudwatch", "s3", "firehose"], lower(var.waf_log_destination))
    error_message = "waf_log_destination must be one of: cloudwatch, s3, firehose."
  }
}

variable "waf_log_retention_days" {
  description = "Retention for WAF CloudWatch log group."
  type        = number
  default     = 14
}

variable "enable_waf_sampled_requests_only" {
  description = "If true, students can optionally filter/redact fields later. (Placeholder toggle.)"
  type        = bool
  default     = false
}

variable "cloudfront_waf_arn" {
  type        = string
  description = "ARN of the CloudFront-scoped WAF web ACL"
  default     = null
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB from the network module"
  type        = string
}


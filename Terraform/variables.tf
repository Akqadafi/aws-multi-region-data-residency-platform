########################################
# ROOT VARIABLES (lab1c/variables.tf)
########################################

variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
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

########################################
# NETWORK
########################################

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to use. Must align with subnet CIDR counts."
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "manage_route53_in_terraform" {
  description = "If true, create/manage Route53 hosted zone + records in Terraform."
  type        = bool
  default     = true
}

variable "route53_hosted_zone_id" {
  description = "If manage_route53_in_terraform=false, provide existing Hosted Zone ID for domain."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Primary domain for the application (e.g., arcanum-base.click)"
  type        = string
}

variable "app_subdomain" {
  description = "Subdomain for the app (e.g., 'app' for app.example.com)."
  type        = string
  default     = "app"
}

variable "route53_zone_name" {
  description = "Base domain hosted in Route53 (e.g., 'example.com')."
  type        = string
  default     = "arcanum-base.click"
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logging to S3."
  type        = bool
  default     = true
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = "alb-access-logs"
}

########################################
# SECURITY
########################################

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form for SSH access (e.g., 203.0.113.10/32)."
  type        = string
  # No default on purpose: forces you to set it safely
}

variable "waf_log_destination" {
  description = "Choose ONE destination per WebACL: cloudwatch | s3 | firehose"
  type        = string
  default     = "cloudwatch"
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

########################################
# DATABASE (RDS + Secret)
########################################

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql"
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "storage_type" {
  description = "RDS storage type."
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "arcdb"
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password."
  type        = string
  sensitive   = true
  # No default on purpose
}

########################################
# EC2 APP
########################################

variable "ec2_instance_type" {
  description = "EC2 instance type for app host."
  type        = string
  default     = "t3.micro"
}
variable "associate_public_ip" {
  type    = bool
  default = false
}
########################################
# MONITORING (SNS)
########################################

variable "sns_email_endpoint" {
  description = "Email address to receive SNS alarm notifications."
  type        = string
  # No default on purpose
}

variable "ami_ssm_parameter_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

########################################
# BONUS G (BEDROCK AUTO INCIDENT REPORT)
########################################

variable "enable_bedrock_auto_ir" {
  description = "Enable Bonus G auto incident reporting pipeline (SNS -> Lambda -> S3 + Bedrock summarization)."
  type        = bool
  default     = true
}

variable "bedrock_model_id" {
  description = "Bedrock model ID used by IncidentReporter Lambda (example: anthropic.claude-3-haiku-20240307-v1:0)."
  type        = string
  default     = "anthropic.claude-3-haiku-20240307-v1:0"
}

variable "auto_ir_mode" {
  description = "Incident report depth mode: fast (15m) or deep (60m)."
  type        = string
  default     = "fast"

  validation {
    condition     = contains(["fast", "deep"], lower(var.auto_ir_mode))
    error_message = "auto_ir_mode must be one of: fast, deep."
  }
}

variable "auto_ir_fast_window_minutes" {
  description = "Time window in minutes for fast report mode."
  type        = number
  default     = 15

  validation {
    condition     = var.auto_ir_fast_window_minutes >= 1 && var.auto_ir_fast_window_minutes <= 60
    error_message = "auto_ir_fast_window_minutes must be between 1 and 60."
  }
}

variable "auto_ir_reports_prefix" {
  description = "S3 key prefix for generated incident report artifacts."
  type        = string
  default     = "reports"
}

variable "enable_separate_report_ready_topic" {
  description = "If true, create a dedicated SNS topic for IncidentReporter output notifications."
  type        = bool
  default     = true
}

variable "report_ready_topic_arn" {
  description = "Optional existing SNS topic ARN for IncidentReporter output notifications."
  type        = string
  default     = ""
}

variable "enable_origin_cloaking" {
  description = "Enable Lab 2 CloudFront origin cloaking pattern"
  type        = bool
  default     = true
}

# variable "region" {
#   type    = string
#   default = "ap-northeast-1"
# }

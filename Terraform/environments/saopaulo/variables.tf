########################################
# Sao Paulo Root Variables
########################################

variable "project_name" {
  description = "Name prefix used for tagging and resource naming."
  type        = string
  default     = "liberdade"
}

variable "env" {
  description = "Environment name."
  type        = string
  default     = "lab"
}

variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "sa-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

########################################
# NETWORK
########################################

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.20.0.0/16"
}

variable "azs" {
  description = "Availability zones to use."
  type        = list(string)
  default     = ["sa-east-1a", "sa-east-1c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs, one per AZ."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "manage_route53_in_terraform" {
  description = "If true, create/manage Route53 hosted zone + records in Terraform."
  type        = bool
  default     = false
}

variable "route53_hosted_zone_id" {
  description = "If manage_route53_in_terraform=false, provide existing Hosted Zone ID for domain."
  type        = string
  default     = ""
}

variable "route53_zone_name" {
  description = "Base domain hosted in Route53."
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

variable "enable_origin_cloaking" {
  description = "Enable Lab 2 CloudFront origin cloaking pattern"
  type        = bool
  default     = true
}

########################################
# SECURITY
########################################

variable "my_ip_cidr" {
  description = "Your public IP in CIDR form."
  type        = string
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
  description = "Optional sampled requests only toggle."
  type        = bool
  default     = false
}

########################################
# EC2 APP
########################################

variable "ec2_instance_type" {
  description = "EC2 instance type for app host."
  type        = string
  default     = "t3.micro"
}

variable "ami_ssm_parameter_name" {
  type    = string
  default = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

########################################
# TOKYO REMOTE / CROSS-REGION INPUTS
########################################

variable "tokyo_secret_arn" {
  description = "Tokyo secret ARN used by Sao Paulo app/iam if needed."
  type        = string
  default     = ""
}

variable "saopaulo_log_group_arn" {
  description = "CloudWatch log group ARN for Sao Paulo app if needed."
  type        = string
  default     = ""
}

variable "tokyo_tgw_id" {
  type = string
}

variable "tokyo_tgw_peering_attachment_id" {
  type = string
}

variable "tokyo_vpc_cidr" {
  type = string
}
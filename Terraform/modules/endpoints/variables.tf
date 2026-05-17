variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "private_route_table_id" { type = string }
variable "vpce_security_group_id" { type = string }
variable "aws_region" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

variable "domain_name" {
  description = "Primary domain for the application (e.g., arcanum-base.click)"
  type        = string
  default     = "arcanum-base.click"
}

variable "app_subdomain" {
  description = "Subdomain for the app (e.g., 'app' for app.example.com)."
  type        = string
  default     = "app"
}

variable "cloudfront_waf_arn" {
  type        = string
  description = "ARN of the CloudFront-scoped WAF web ACL"
  default     = null
}

variable "cloudfront_acm_cert_arn" {
  description = "Optional existing us-east-1 ACM cert ARN for CloudFront"
  type        = string
  default     = null
}

variable "enable_origin_cloaking" {
  description = "Lab 2: lock ALB to CloudFront + require secret header"
  type        = bool
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logging to S3."
  type        = bool
  default     = true
}

variable "route53_zone_name" {
  description = "Base domain hosted in Route53 (e.g., 'example.com')."
  type        = string
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

  validation {
    condition     = var.manage_route53_in_terraform || length(var.route53_hosted_zone_id) > 0
    error_message = "You must provide route53_hosted_zone_id when manage_route53_in_terraform=false."
  }
}

variable "alb_access_logs_bucket" {
  type    = string
  default = null
  # description = "S3 bucket name for ALB access logs. Required if enable_alb_access_logs is true."
}

variable "certificate_validation_method" {
  description = "ACM certificate validation method. Use 'DNS' for Route53 automation."
  type        = string
  default     = "DNS"
  validation {
    condition     = contains(["DNS", "EMAIL"], upper(var.certificate_validation_method))
    error_message = "certificate_validation_method must be DNS or EMAIL."
  }
}

variable "alb_dns_name" {
  description = "DNS name of the ALB from the network module"
  type        = string
}

variable "origin_header_name" {
  type = string
}

variable "origin_header_value" {
  type      = string
  sensitive = true
}
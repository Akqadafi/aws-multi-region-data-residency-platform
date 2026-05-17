variable "vpc_cidr" { type = string }
variable "public_subnet_cidrs" { type = list(string) }
variable "private_subnet_cidrs" { type = list(string) }
variable "azs" { type = list(string) }

variable "tags" {
  type    = map(string)
  default = {}
}
variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}

variable "alb_access_logs_prefix" {
  description = "S3 prefix for ALB access logs."
  type        = string
  default     = "alb-access-logs"
}

variable "alb_logs_bucket_name" {
  description = "Optional override: explicit S3 bucket name for ALB logs. If null, a default is generated."
  type        = string
  default     = null

}


variable "alb_allow_public_http_https" {
  description = "If true, ALB allows public HTTP/HTTPS ingress (Lab 1). If false, ALB is locked down for CloudFront only (Lab 2)."
  type        = bool
  default     = true
}

variable "enable_alb_access_logs" {
  description = "Enable ALB access logging to S3."
  type        = bool
  default     = true
}


# variable "domain_name" {
#   description = "Primary domain for the application (e.g., arcanum-base.click)"
#   type        = string
#   default     = "arcanum-base.click"
# }

# variable "app_subdomain" {
#   description = "Subdomain for the app (e.g., 'app' for app.example.com)."
#   type        = string
#   default     = "app"
# }



variable "route53_zone_id" {
  description = "Public Route53 hosted zone ID used for ALB certificate DNS validation"
  type        = string
  default     = null
}

variable "alb_access_logs_bucket" {
  type    = string
  default = null
  # description = "S3 bucket name for ALB access logs. Required if enable_alb_access_logs is true."
}


 
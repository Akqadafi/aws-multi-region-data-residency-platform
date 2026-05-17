variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}
variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "ap-northeast-1"
}

variable "secret_arn_guess" {
  type    = string
  default = ""
}

variable "cloudwatch_log_group_arn" {
  type    = string
  default = ""
}
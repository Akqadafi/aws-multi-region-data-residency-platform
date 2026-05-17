variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "rds_security_group_id" { type = string }

variable "db_engine" { type = string }
variable "db_instance_class" { type = string }
variable "storage_type" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

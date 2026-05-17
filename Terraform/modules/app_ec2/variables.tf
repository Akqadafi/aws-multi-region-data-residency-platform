variable "project_name" {
  description = "Name prefix used for tagging and resource naming (e.g., arcanum, shibuya)."
  type        = string
  default     = "arcanum"
}
variable "ec2_security_group_id" { type = string }
variable "ec2_instance_type" { type = string }
variable "subnet_id" {
  type = string
}

variable "ami_ssm_parameter_name" { type = string }

# Default keeps your original behavior but expects 1a_user_data.sh inside this module folder.
variable "user_data_file" {
  type    = string
  default = "1a_user_data.sh"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "associate_public_ip" {
  type    = bool
  default = false
}
variable "iam_instance_profile_name" {
  type = string
}

variable "aws_profile" {
  type    = string
  default = "default"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
variable "aws_profile" {
  type    = string
  default = "default"
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
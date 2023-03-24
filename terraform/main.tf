provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Terraform = true
    }
  }
}

provider "template" {
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name     = "demo"
  prefix   = "tf"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Environment = local.name
  }
}

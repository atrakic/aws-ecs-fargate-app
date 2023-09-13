provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Terraform = element(local.here, length(local.here) - 1)
    }
  }
}

provider "template" {
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  here     = split("/", abspath(path.cwd)) // current working directory
  name     = "demo"
  prefix   = "tf"
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Environment = local.name
  }
}

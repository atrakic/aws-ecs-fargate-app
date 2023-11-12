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
  here = split("/", abspath(path.cwd))
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = {
    Workspace = terraform.workspace
    Author    = data.aws_caller_identity.current.id
  }
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=26c38a66f12e7c6c93b6a2ba127ad68981a48671" # commit hash of version 5.0.0
  name   = var.name

  cidr = local.cidr
  azs  = local.azs

  public_subnets  = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 10)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

module "app" {
  source = "./ecs-fargate"
  name   = var.name
  prefix = "tf"
  app    = var.app

  vpc = {
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
  }
  tags = local.tags
}

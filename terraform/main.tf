data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  tags = merge(var.tags, {
    Workspace = terraform.workspace
    Owner     = data.aws_caller_identity.current.id
  })
}

module "db" {
  source    = "./modules/dynamodb"
  hash_key  = "artist"
  range_key = "title"

  configuration = {
    name = var.name
    attribute = [
      {
        name = "artist"
        type = "S"
      },
      {
        name = "title"
        type = "S"
      }
    ]
    global_secondary_indexes = [
      {
        name            = "TitleIndex"
        hash_key        = "artist"
        range_key       = "title"
        projection_type = "INCLUDE"
      }
    ]
  }
  tags = local.tags
}

module "app" {
  source           = "./modules/ecs-fargate"
  name             = var.name
  prefix           = "tf"
  app              = var.app
  alb_tls_cert_arn = var.alb_tls_cert_arn

  # workaround for localstack since it requires ECS with license :/
  count = data.aws_caller_identity.current.account_id != "000000000000" ? 1 : 0

  vpc = {
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
  }

  tags = local.tags
}

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=2e417ad0ce830893127476436179ef483485ae84"
  name   = var.name

  cidr                 = local.cidr
  azs                  = local.azs
  public_subnets       = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k)]
  private_subnets      = [for k, v in local.azs : cidrsubnet(local.cidr, 8, k + 10)]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  tags                 = local.tags
}

module "sns" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-sns.git?ref=6404f81a23544d2aba6c9c178cdf97290cee0e90"

  name   = var.pub_sub_name
  create = var.pub_sub_name == "" ? false : true

  topic_policy_statements = {
    sqs = {
      sid = "SQSSubscribe"
      actions = [
        "sns:Subscribe",
        "sns:Receive",
      ]

      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]

      conditions = [{
        test     = "StringLike"
        variable = "sns:Endpoint"
        values   = [module.sqs.queue_arn]
      }]
    }
  }

  subscriptions = {
    sqs = {
      protocol = "sqs"
      endpoint = module.sqs.queue_arn
    }
  }

  tags = var.tags
}

module "sqs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-sqs.git?ref=8c18f70fd765db2adf31edf5fc15b3058367e5a2"

  name   = var.pub_sub_name
  create = var.pub_sub_name == "" ? false : true

  create_queue_policy = true
  queue_policy_statements = {
    sns = {
      sid     = "SNSPublish"
      actions = ["sqs:SendMessage"]

      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]

      conditions = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [module.sns.topic_arn]
      }]
    }
  }

  tags = var.tags
}

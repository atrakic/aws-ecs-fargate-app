data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

module "app" {
  source = "./modules/ecs-fargate"

  name             = "ecs-fargate"
  prefix           = "tf"
  alb_tls_cert_arn = var.alb_tls_cert_arn

  app = { for k, v in var.fargate_apps :
    k => {
      name              = v.name
      host_header       = v.host_header
      image             = v.image
      port              = v.port
      health_check_path = v.health_check_path
      desired_count     = v.desired_count
      fargate_cpu       = v.fargate_cpu
      fargate_memory    = v.fargate_memory
    }
  }

  vpc = {
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
  }

  depends_on = [module.vpc, module.db, module.sns, module.sqs]
  tags       = local.tags
}

module "db" {
  source    = "./modules/dynamodb"
  hash_key  = "artist"
  range_key = "title"

  configuration = {
    name = "${local.name}-dynamodb"
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

module "vpc" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=2e417ad0ce830893127476436179ef483485ae84"
  name   = "${local.name}-vpc"

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

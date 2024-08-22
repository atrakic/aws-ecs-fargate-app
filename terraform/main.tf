data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}


module "ecs" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-ecs.git?ref=3b70e1e46e1b96a2da7fbfe6e2c11d44009607f1"

  cluster_name = "${local.name}-ecs-cluster"
  create       = local.create_fargate_apps

  services = {
    ecs-demo = {
      cpu        = 1024
      memory     = 4096

      ## Task Definition
      container_definitions = {
        worker = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "ghcr.io/atrakic/aws-worker:latest"
          environment = [
            {
              name  = "AWS_DEFAULT_REGION"
              value = data.aws_region.current.name
            },
            {
              name  = "QUEUE_URL"
              value = module.sqs.queue_url
            }
          ]
        }
        publisher = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "ghcr.io/atrakic/aws-publisher:latest"
          port_mappings = [{
            name          = "http"
            containerPort = 8000
            hostPort      = 8000
            protocol      = "tcp"
          }]
          dependencies = [{
            containerName = "worker"
            condition     = "START"
          }]
          environment = [
            {
              name  = "AWS_DEFAULT_REGION"
              value = data.aws_region.current.name
            },
            {
              name  = "TABLE_NAME"
              value = module.db.table_name
            },
            {
              name  = "TOPIC_ARN"
              value = module.sns.topic_arn
            }
          ]
        }
      }

      ## Load Balancer
      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["publisher"].arn
          container_name   = "publisher"
          container_port   = "8000"
        }
      }

      ## IAM      
      tasks_iam_role_name        = "${local.name}-tasks"
      tasks_iam_role_description = "ECS tasks IAM role for ${local.name}"
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }

      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        },
        {
          actions   = ["sqs:ListQueues"]
          resources = ["*"]
        },
        {
          actions   = ["sns:ListTopics"]
          resources = ["*"]
        },
        {
          actions   = ["dynamodb:ListTables"]
          resources = ["*"]
        },
        {
          actions   = ["dynamodb:DescribeTable"]
          resources = ["*"]
        },
        {
          actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem", "dynamodb:DeleteItem"]
          resources = ["arn:aws:dynamodb:*:*:table/*"]
        },
        {
          actions   = ["dynamodb:Query", "dynamodb:Scan"]
          resources = ["arn:aws:dynamodb:*:*:table/*/index/*"]
        },
        {
          actions   = ["sns:Publish"]
          resources = ["*"]
        },
        {
          actions   = ["sqs:SendMessage"]
          resources = ["*"]
        },
        {
          actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage"]
          resources = ["*"]
        },
        {
          actions   = ["sqs:GetQueueAttributes"]
          resources = ["*"]
        }
      ]

      ## Security Group
      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress_8000 = {
          type                     = "ingress"
          from_port                = 8000
          to_port                  = 8000
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  tags = local.tags
}

module "alb" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-alb.git?ref=349540d1a611cd98a6383cc64ef0d9bf08d88fb7"

  create             = var.create
  name               = "${local.name}-alb"
  load_balancer_type = "application"

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = var.alb_tls_cert_arn
      forward = {
        target_group_key = "publisher"
      }
    }
  }

  target_groups = {
    publisher = {
      backend_protocol     = "HTTP"
      backend_port         = 8000
      target_type          = "ip"
      protocol             = "HTTP"
      deregistration_delay = 5
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false

      health_check = {
        path     = "/healthcheck"
        interval = 30
        matcher  = "200"
        port     = "traffic-port"
        protocol = "HTTP"
        timeout  = 5
      }
    }
  }

  tags = local.tags
}

module "db" {
  source = "./modules/dynamodb"

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

  tags = local.tags
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

  public_subnet_tags = {
    Tier = "public"
  }

  private_subnet_tags = {
    Tier = "private"
  }

  tags = local.tags
}

### CloudMap and ACM

data "aws_route53_zone" "this" {
  count = var.create && var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

resource "aws_service_discovery_http_namespace" "this" {
  count       = var.create ? 1 : 0
  name        = "${local.name}-sdns"
  description = "CloudMap namespace for ${local.name}"
  tags        = local.tags
}

module "acm" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-acm.git?ref=0ca52d1497e5a54ed86f9daac0440d27afc0db8b"

  create_certificate = var.create && var.domain_name != "" ? true : false
  domain_name        = var.domain_name
  zone_id            = concat(data.aws_route53_zone.this.*.id, [""], )[0]
}

module "wildcard_cert" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-acm.git?ref=0ca52d1497e5a54ed86f9daac0440d27afc0db8b"

  create_certificate = var.create && var.domain_name != "" ? true : false
  domain_name        = "*.${var.domain_name}"
  zone_id = concat(data.aws_route53_zone.this.*.id, [""], )[0]
}

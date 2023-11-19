module "app" {
  source           = "./modules/ecs-fargate"
  name             = var.name
  prefix           = "tf"
  app              = var.app
  alb_tls_cert_arn = var.alb_tls_cert_arn

  vpc = {
    vpc_id          = module.vpc.vpc_id
    public_subnets  = module.vpc.public_subnets
    private_subnets = module.vpc.private_subnets
  }
  tags = local.tags
}

output "alb_hostname" {
  value = module.app.alb_hostname
}

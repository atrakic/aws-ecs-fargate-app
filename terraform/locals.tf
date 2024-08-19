locals {
  name = "ecs-fargate-${basename(path.cwd)}"

  # Localstack requires license with ECS Fargate
  create_fargate_apps = length(var.fargate_apps) > 0 && data.aws_caller_identity.current.account_id != "000000000000" ? true : false

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = merge(var.tags, {
    Workspace = terraform.workspace
    Owner     = data.aws_caller_identity.current.id
  })
}

# outputs.tf

output "self" {
  description = "Runtime environment"
  value = merge({
    caller_arn          = data.aws_caller_identity.current.arn,
    create_fargate_apps = local.create_fargate_apps,
    last_update         = timestamp()
  }, local.tags)
}
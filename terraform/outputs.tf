# outputs.tf

output "self" {
  description = "Runtime environment"
  value = merge({
    caller_arn  = data.aws_caller_identity.current.arn,
    last_update = timestamp()
  }, local.tags)
}

/**
output "alb_hostname" {
  value = module.app.alb_hostname
}
*/

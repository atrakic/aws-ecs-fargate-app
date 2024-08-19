# outputs.tf

output "self" {
  description = "Runtime environment"
  value = merge({
    caller_arn  = data.aws_caller_identity.current.arn,
    last_update = timestamp()
  }, local.tags)
}

/* 
output "fargate_apps" {
  value = formatlist("%s://%s:%s", "http", module.app.alb_dns_name, "80")
}
*/
# outputs.tf

output "self" {
  description = "Runtime environment"
  value = {
    workspace   = terraform.workspace
    caller_arn  = data.aws_caller_identity.current.arn
    last_update = timestamp()
  }
}

output "alb_hostname" {
  value = aws_alb.this.dns_name
}

# outputs.tf

output "self" {
  description = "Runtime environment"
  value = merge({
    caller_arn         = data.aws_caller_identity.current.arn,
    localstack_enabled = local.localstack_enabled,
    last_update        = timestamp()
  }, local.tags)
}

output "table_name" {
  description = "DynamoDB table name"
  value       = module.db.table_name
}

output "sqs_queue_name" {
  description = "SQS queue name"
  value       = module.sqs.queue_name
}

output "sns_topic_name" {
  description = "SNS topic name"
  value       = module.sns.topic_name
}

# logs.tf

# Set up CloudWatch group and log stream and retain logs
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${local.app_name}"
  #checkov:skip=CKV_AWS_158:"Ensure that CloudWatch Log Group is encrypted by KMS"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "${local.prefix}-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

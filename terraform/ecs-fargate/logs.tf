# logs.tf

# Set up CloudWatch group and log stream and retain logs
resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/${var.name}"

  #checkov:skip=CKV_AWS_338:"Ensure CloudWatch log groups retains logs for at least 1 year"
  #checkov:skip=CKV_AWS_158:"Ensure that CloudWatch Log Group is encrypted by KMS"

  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "${var.prefix}-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}

name = "flask-app"
app = {
  host_header       = "app.foo.bar"
  image             = "ghcr.io/atrakic/aws-dynamodb-app:latest"
  port              = 8000
  desired_count     = "1"
  health_check_path = "/healthcheck"
  fargate_cpu       = "256"
  fargate_memory    = "512"
}

app = {
  host_header       = "foo.bar.com"
  image             = "ghcr.io/atrakic/octocat-app"
  image_version     = "latest"
  port              = 8080
  desired_count     = "1"
  health_check_path = "/"
  fargate_cpu       = "256"
  fargate_memory    = "512"
}

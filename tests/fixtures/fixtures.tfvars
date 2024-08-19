name = "fixtures-stack"

pub_sub_name = "pub-sub"

fargate_apps = {
  publisher = {
    name              = "publisher"
    host_header       = "publisher.foo.bar"
    image             = "ghcr.io/atrakic/aws-publisher:latest"
    port              = 8000
    health_check_path = "/healthcheck"
  }
  subscriber = {
    name              = "subscriber"
    image             = "ghcr.io/atrakic/aws-subscriber:latest"
    host_header       = null
    port              = null
    health_check_path = null
  }
}

tags = {
  Fixtures = "true"
}

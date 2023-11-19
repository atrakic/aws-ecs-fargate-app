# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }
}

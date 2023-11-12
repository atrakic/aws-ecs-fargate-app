# app.tf

locals {
  _app_list = split("/", var.app.image)
  app_name  = element(local._app_list, length(local._app_list) - 1)
}

data "template_file" "app" {
  template = file("${path.module}/templates/ecs/app.json.tmpl")

  vars = {
    app_name          = local.app_name
    app_image         = var.app.image
    app_image_version = var.app.image_version
    app_port          = var.app.port
    fargate_cpu       = var.app.fargate_cpu
    fargate_memory    = var.app.fargate_memory
    aws_region        = var.aws_region
    awslogs-group     = "/ecs/${local.app_name}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.app_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app.fargate_cpu
  memory                   = var.app.fargate_memory
  container_definitions    = data.template_file.app.rendered
}

resource "aws_ecs_service" "app" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets         = var.vpc.private_subnets
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.app_name
    container_port   = var.app.port
  }

  depends_on = [
    aws_alb_listener.this,
  aws_iam_role_policy_attachment.ecs_task_execution_role]

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}

resource "aws_alb_target_group" "app" {
  name        = "${var.prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.app.health_check_path
    unhealthy_threshold = "2"
  }
  tags = var.tags
}

resource "aws_alb_listener_rule" "app_https" {
  listener_arn = aws_alb_listener.this.arn

  action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }

  condition {
    host_header {
      values = [var.app.host_header]
    }
  }
}

resource "aws_service_discovery_private_dns_namespace" "app" {
  name        = "${local.app_name}.${terraform.workspace}.local"
  description = "${local.app_name} private dns namespace"
  vpc         = var.vpc.vpc_id
}

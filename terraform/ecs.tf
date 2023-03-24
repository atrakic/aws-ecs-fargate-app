# ecs.tf

locals {
  _app_list = split("/", var.app_image)
  app_name  = element(local._app_list, length(local._app_list) - 1)
}

resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

data "template_file" "app" {
  template = file("./templates/ecs/app.json.tmpl")

  vars = {
    app_name          = local.app_name
    app_image         = var.app_image
    app_image_version = var.app_image_version
    app_port          = var.app_port
    fargate_cpu       = var.app_fargate_cpu
    fargate_memory    = var.app_fargate_memory
    aws_region        = var.aws_region
    awslogs-group     = "/ecs/${local.app_name}"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = local.app_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_fargate_cpu
  memory                   = var.app_fargate_memory
  container_definitions    = data.template_file.app.rendered
}

resource "aws_ecs_service" "app" {
  name            = local.app_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.app_name
    container_port   = var.app_port
  }

  depends_on = [aws_alb_listener.app, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

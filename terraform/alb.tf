# alb.tf

#tfsec:ignore:aws-elb-alb-not-public
resource "aws_alb" "main" {
  name                       = "${var.prefix}-load-balancer"
  subnets                    = aws_subnet.public.*.id
  security_groups            = [aws_security_group.lb.id]
  drop_invalid_header_fields = true
  preserve_host_header       = false
  enable_deletion_protection = false
  tags                       = local.tags
}

resource "aws_alb_target_group" "app" {
  name        = "${var.prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.app_health_check_path
    unhealthy_threshold = "2"
  }
  tags = local.tags
}

# Redirect all traffic from the ALB to the target group
#tfsec:ignore:http-not-used
resource "aws_alb_listener" "app" {
  load_balancer_arn = aws_alb.main.id
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

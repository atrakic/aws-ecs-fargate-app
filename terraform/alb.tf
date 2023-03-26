# alb.tf

#tfsec:ignore:aws-elb-alb-not-public
resource "aws_alb" "main" {
  name                       = "${local.prefix}-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.lb.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = false
  tags                       = local.tags
}

resource "aws_alb_target_group" "app" {
  name        = "${local.prefix}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
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
resource "aws_alb_listener" "app_http" {
  count             = var.alb_tls_cert_arn == "" ? 1 : 0
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app.id
  }
}

# test: terraform plan -var 'alb_tls_cert_arn=arn:aws:acm:eu-west-1:123456789012:certificate/tf-acc-test-6453083910015726063'
resource "aws_alb_listener" "app_https_redirect" {
  count             = var.alb_tls_cert_arn == "" ? 0 : 1
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "app_https" {
  count             = var.alb_tls_cert_arn == "" ? 0 : 1
  load_balancer_arn = aws_alb.main.id
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.alb_tls_cert_arn

  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}

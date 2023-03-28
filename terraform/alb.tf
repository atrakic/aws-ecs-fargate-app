# alb.tf

locals {
  certificate_arn = coalesce(module.self_signed_cert.acm_certificate_arn, var.alb_tls_cert_arn)
}

#tfsec:ignore:aws-elb-alb-not-public
resource "aws_alb" "this" {

  #checkov:skip=CKV2_AWS_20:"Ensure that ALB redirects HTTP requests into HTTPS ones"
  #checkov:skip=CKV2_AWS_28:"Ensure public facing ALB are protected by WAF"
  #checkov:skip=CKV_AWS_91:"Ensure the ELBv2 (Application/Network) has access logging enabled"

  name                       = "${local.prefix}-load-balancer"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = module.vpc.public_subnets
  security_groups            = [aws_security_group.lb.id]
  drop_invalid_header_fields = true
  enable_deletion_protection = true
  tags                       = local.tags
}

module "self_signed_cert" {
  source  = "./modules/self_signed_cert"
  enabled = var.alb_tls_cert_arn == "" ? true : false
  tags    = local.tags
}

resource "aws_alb_listener" "this" {
  load_balancer_arn = aws_alb.this.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = local.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

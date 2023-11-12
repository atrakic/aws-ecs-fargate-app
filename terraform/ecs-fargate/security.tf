# security.tf

#tfsec:ignore:no-public-egress-sgr tfsec:ignore:no-public-ingress-sgr
resource "aws_security_group" "lb" {
  name        = "${var.prefix}-load-balancer-security-group"
  description = "Access to the ALB"
  vpc_id      = var.vpc.vpc_id

  ingress {
    description      = "Ingress ${var.app.port} access for ALB"
    protocol         = "tcp"
    from_port        = var.app.port
    to_port          = var.app.port
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Ingress HTTPS access for ALB"
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Egress access for ALB"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = var.tags
}

# Traffic to the ECS task should only come from the ALB
#tfsec:ignore:no-public-egress-sgr
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.prefix}-ecs-tasks-security-group"
  description = "Allow inbound access from the ALB only"
  vpc_id      = var.vpc.vpc_id

  ingress {
    description     = "Ingress access for ECS task (but only from ALB)"
    protocol        = "tcp"
    from_port       = var.app.port
    to_port         = var.app.port
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    description      = "Egress access for ECS task"
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.tags
}

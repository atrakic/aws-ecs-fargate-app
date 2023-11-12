# variables.tf

variable "aws_region" {
  description = "The AWS region things are created in"
  type        = string
  default     = "eu-west-1"
}

variable "name" {
  type = string
}

variable "alb_tls_cert_arn" {
  description = "(Optional) The ARN of the certificate that the ALB uses for https"
  type        = string
  default     = ""
}

variable "prefix" {
  type    = string
  default = "tf"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc" {
  type = object({
    vpc_id          = string
    public_subnets  = list(string)
    private_subnets = list(string)
  })
}

variable "app" {
  type = object({
    host_header       = string
    image             = string
    image_version     = string
    port              = string
    desired_count     = string
    health_check_path = string
    fargate_cpu       = string
    fargate_memory    = string
  })
  default = {
    host_header       = "foo.bar.com"
    image             = "nginx"
    image_version     = "latest"
    port              = "80"
    desired_count     = "1"
    health_check_path = "/"
    fargate_cpu       = "256"
    fargate_memory    = "512"
  }
}

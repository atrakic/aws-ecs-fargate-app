# variables.tf

variable "name" {
  type = string
}

variable "aws_region" {
  description = "The AWS region things are created in"
  type        = string
  default     = "eu-west-1"
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
}

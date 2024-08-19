# variables.tf

variable "fargate_apps" {
  description = "A map of fargate apps to create"
  type = map(object({
    name              = string
    host_header       = string
    image             = string
    port              = string
    desired_count     = optional(string, "1")
    health_check_path = string
    fargate_cpu       = optional(string, "256")
    fargate_memory    = optional(string, "512")
  }))
  default = {
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
      port              = 9999
      health_check_path = null
    }
  }
}

variable "alb_tls_cert_arn" {
  description = "(Optional) The ARN of the certificate that the ALB uses for https"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "pub_sub_name" {
  description = "(Optional) The name of the SQS/SNS pub-sub to create"
  type        = string
  default     = ""
}

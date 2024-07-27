# variables.tf

variable "name" {
  type = string
}

variable "app" {
  type = object({
    host_header       = string
    image             = string
    port              = string
    desired_count     = string
    health_check_path = string
    fargate_cpu       = string
    fargate_memory    = string
  })
  default = {
    host_header       = "demo.example.com"
    image             = "nginx:latest"
    port              = "8000"
    desired_count     = "1"
    health_check_path = "/"
    fargate_cpu       = "256"
    fargate_memory    = "512"
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

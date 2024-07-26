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
}

variable "alb_tls_cert_arn" {
  description = "(Optional) The ARN of the certificate that the ALB uses for https"
  type        = string
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
}

variable "prefix" {
  type        = string
  description = "Prefix to add to all resources"
  default     = "flask-app"
}

# variables.tf

variable "create" {
  description = "Determines whether resources will be created (affects all resources)"
  type        = bool
  default     = true
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
  default     = "pub-sub"
}

variable "domain_name" {
  description = "The domain name to use for the Route 53 hosted zone"
  type        = string
  default     = ""
}

# variables.tf

variable "prefix" {
  description = "Prefix to use"
  type        = string
  default     = "tf"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  type        = string
  default     = "eu-west-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  type        = string
  default     = "2"
}

variable "app_image" {
  description = "Container image to run in the ECS cluster"
  type        = string
  default     = "nginx"
}

variable "app_image_version" {
  description = "Docker image version to run in the ECS cluster, eg v1.0.0 or latest"
  type        = string
  default     = "latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  type        = string
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  type        = string
  default     = 1
}

variable "app_health_check_path" {
  type    = string
  default = "/"
}

variable "app_fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = string
  default     = "256"
}

variable "app_fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = string
  default     = "512"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.58"
    }

    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }
  }

  # ##  Used for end-to-end testing on project;
  # backend "s3" {
  #   bucket = "tfstate-atrakic-github-actions-state"
  #   region = "eu-west-1"
  #   key    = "e2e/terraform-aws-ecs-fargate/terraform.tfstate"
  # }
}

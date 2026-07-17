terraform {
  required_version = "> 1.12, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 6.28.0"
    }
  }

  backend "s3" {
    use_lockfile = true
    encrypt      = true
  }
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}




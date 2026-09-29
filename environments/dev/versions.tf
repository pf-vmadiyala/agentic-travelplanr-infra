terraform {
  required_version = "> 1.12, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = ">= 6.28.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.13.1"
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
  default     = "us-east-2"
}


variable "eks_public_access_cidrs" {
  description = "IPs allowed to reach the public EKS API endpoint (set in dev.tfvars)"
  type        = list(string)
}




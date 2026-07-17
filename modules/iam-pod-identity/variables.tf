variable "cluster_name" {
  description = "EKS cluster name (used in role names and associations)"
  type        = string
  default     = "agentic-travel-planner-dev"
}

variable "secret_name_prefix" {
  description = "Secrets Manager name prefix to scope read access, e.g. agentic-travel-planner/dev"
  type        = string
  default     = "agentic-travel-planner/dev"
}

variable "app_namespace" {
  description = "Namespace where the API and worker pods run"
  type        = string
  default     = "travel-planner"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}
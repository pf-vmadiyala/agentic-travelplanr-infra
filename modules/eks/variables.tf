variable "cluster_name" {
  description = "Name of the EKS cluster (must match the VPC subnet tags)"
  type        = string
  default     = "agentic-travel-planner-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the control plane"
  type        = string
  default     = "1.31"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

# --- Network (from the vpc module) ---
variable "vpc_id" {
  description = "VPC ID from the vpc module"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs where nodes are launched"
  type        = list(string)
}

# --- System node group ---
variable "system_instance_types" {
  description = "Instance types for the system node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "system_min_size" {
  description = "Minimum size of the system node group"
  type        = number
  default     = 2
}

variable "system_max_size" {
  description = "Maximum size of the system node group"
  type        = number
  default     = 4
}

variable "system_desired_size" {
  description = "Desired size of the system node group"
  type        = number
  default     = 2
}

# --- App node group ---
variable "app_instance_types" {
  description = "Instance types for the app node group"
  type        = list(string)
  default     = ["t3.large"]
}

variable "app_min_size" {
  description = "Minimum size of the app node group"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "Maximum size of the app node group"
  type        = number
  default     = 6
}

variable "app_desired_size" {
  description = "Desired size of the app node group"
  type        = number
  default     = 2
}

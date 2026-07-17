variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "azs" {
  description = "list of availability zones (if null, dynamically queries region zones)"
  type        = list(string)
  default     = null
}
variable "private_subnets" {
  description = "list of private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}
variable "public_subnets" {
  description = "list of public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}
variable "single_nat_gateway" {
  description = "flag to enable single NAT Gateway"
  type        = bool
  default     = true
}
variable "cluster_name" {
  description = "Name of EKS Cluster"
  type        = string
}

variable "cluster_name" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
variable "cluster_ca_data" {
  description = "Base64 cluster CA cert from the eks module"
  type        = string
}
variable "region" {
  type    = string
  default = "us-east-1"
}
variable "vpc_id" {
  type = string
}

variable "gitops_repo_url" {
  description = "Public GitOps repo URL"
  type        = string
  default     = "https://github.com/pf-vmadiyala/agentic-travelplanr-gitops.git"
}

# Chart version pins — verify latest before apply
variable "lb_controller_chart_version" {
  type    = string
  default = "1.8.1"
}
variable "eso_chart_version" {
  type    = string
  default = "0.9.19"
}
variable "argocd_chart_version" {
  type    = string
  default = "7.6.12"
}

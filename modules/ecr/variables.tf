# modules/ecr/variables.tf
variable "repo_name" {
  type    = string
  default = "travel-planner/app"
}
variable "environment" {
  type    = string
  default = "dev"
}

variable "agent_name" {
  description = "Name of the agent runtime, e.g. CustomerSupport"
  type        = string
  default     = "CustomerSupport"
}

variable "container_uri" {
  description = "ECR image URI (repo:tag) containing the agent build, e.g. from `agentcore launch`"
  type        = string
}

variable "network_mode" {
  description = "AgentCore Runtime network mode: PUBLIC or VPC"
  type        = string
  default     = "PUBLIC"
}

variable "environment_variables" {
  description = "Environment variables passed to the agent container"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

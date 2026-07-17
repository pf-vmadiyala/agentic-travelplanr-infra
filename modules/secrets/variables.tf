variable "name_prefix" {
  description = "Prefix for all secret names, e.g. travel-planner/dev"
  type        = string
  default     = "agentic-travel-planner/dev"
}

variable "secret_names" {
  description = "List of secret names to create (empty entries)"
  type        = list(string)
  default = [
    "anthropic-api-key",
    "openai-api-key",
    "amadeus-api-key",
    "amadeus-api-secret",
    "xai-api-key",
    "google-maps-api-key",
    "openweathermap-api-key",
    "langsmith-api-key",
    "jwt-secret",
    "db-credentials",
  ]
}

variable "recovery_window_in_days" {
  description = "Recovery window on delete. 0 = delete immediately (dev/trial). Use 7-30 for prod."
  type        = number
  default     = 0
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

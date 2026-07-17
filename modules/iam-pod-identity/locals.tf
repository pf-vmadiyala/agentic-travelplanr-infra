locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "agentic-travel-planner"
  }
}
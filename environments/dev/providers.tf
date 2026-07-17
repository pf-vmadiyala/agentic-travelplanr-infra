
provider "aws" {
    region = var.region

    default_tags {
        tags = {
            Environment  = "dev"
            Project      = "agentic-travel-planner"
            ManagedBy    = "terraform"
            
        }
    }
}
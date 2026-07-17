# modules/ecr/main.tf
resource "aws_ecr_repository" "app" {
  name                 = var.repo_name          # "travel-planner/app"
  image_tag_mutability = "IMMUTABLE"            # SHA tags can't be overwritten
  force_delete         = true                   # dev: destroy even with images (teardown)

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "agentic-travel-planner"
  }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 tagged images"
      selection = {
        tagStatus     = "tagged"
        tagPrefixList = ["v", "sha", ""]  # broad; adjust to your tag scheme
        countType     = "imageCountMoreThan"
        countNumber   = 20
      }
      action = { type = "expire" }
    }]
  })
}
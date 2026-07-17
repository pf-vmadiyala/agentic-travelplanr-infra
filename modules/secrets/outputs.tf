output "secret_arns" {
  description = "Map of secret short-name → full ARN (consumed by iam-irsa and GitOps ExternalSecrets)"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_arn_list" {
  description = "Flat list of all secret ARNs — handy for scoping an IAM policy Resource block"
  value       = [for s in aws_secretsmanager_secret.this : s.arn]
}

output "secret_name_prefix" {
  description = "The name prefix, e.g. agentic-travel-planner/dev — used for wildcard IAM scoping"
  value       = var.name_prefix
}

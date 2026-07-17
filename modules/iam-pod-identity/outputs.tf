output "api_role_arn" {
  description = "API pod role ARN"
  value       = module.api_pod_identity.iam_role_arn
}

output "worker_role_arn" {
  description = "Worker pod role ARN"
  value       = module.worker_pod_identity.iam_role_arn
}

output "eso_role_arn" {
  description = "External Secrets Operator role ARN"
  value       = module.eso_pod_identity.iam_role_arn
}

output "lb_controller_role_arn" {
  description = "AWS Load Balancer Controller role ARN"
  value       = module.lb_controller_pod_identity.iam_role_arn
}

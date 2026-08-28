output "agent_runtime_arn" {
  description = "ARN of the AgentCore agent runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

output "agent_runtime_id" {
  description = "ID of the AgentCore agent runtime"
  value       = aws_bedrockagentcore_agent_runtime.this.agent_runtime_id
}

output "role_arn" {
  description = "ARN of the AgentCore Runtime execution role"
  value       = aws_iam_role.agent_runtime.arn
}

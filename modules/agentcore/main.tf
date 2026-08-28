# Deploys an agent (built via `agentcore launch`, e.g. Strands on Bedrock) to
# Amazon Bedrock AgentCore Runtime, with the execution role AgentCore needs
# to pull the container, log, and invoke Bedrock models on the agent's behalf.
# Equivalent to: agentcore create --name <agent_name> --framework Strands
#                --model-provider Bedrock --memory none

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Confused-deputy protection: only this account's AgentCore resources may
# assume this role.
data "aws_iam_policy_document" "trust" {
  statement {
    sid     = "AssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["bedrock-agentcore.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*"]
    }
  }
}

resource "aws_iam_role" "agent_runtime" {
  name               = "bedrock-agentcore-${var.agent_name}"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = local.tags
}

# Minimum permissions AgentCore Runtime needs to run this agent: pull the
# image, write its logs/traces/metrics, mint workload identity tokens, and
# invoke Bedrock models. See:
# https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-permissions.html
data "aws_iam_policy_document" "execution" {
  statement {
    sid    = "ECRImageAccess"
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }

  statement {
    sid    = "ECRTokenAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "LogGroupAccess"
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*"]
  }

  statement {
    sid       = "LogGroupPolicyAccess"
    effect    = "Allow"
    actions   = ["logs:PutResourcePolicy"]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/${var.agent_name}-*"]
  }

  statement {
    sid       = "LogGroupListAccess"
    effect    = "Allow"
    actions   = ["logs:DescribeLogGroups"]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:*"]
  }

  statement {
    sid    = "LogStreamAccess"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/bedrock-agentcore/runtimes/*:log-stream:*"]
  }

  statement {
    sid    = "Tracing"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "Metrics"
    effect    = "Allow"
    actions   = ["cloudwatch:PutMetricData"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "cloudwatch:namespace"
      values   = ["bedrock-agentcore"]
    }
  }

  statement {
    sid    = "GetAgentAccessToken"
    effect = "Allow"
    actions = [
      "bedrock-agentcore:GetWorkloadAccessToken",
      "bedrock-agentcore:GetWorkloadAccessTokenForJWT",
    ]
    resources = [
      "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default",
      "arn:aws:bedrock-agentcore:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:workload-identity-directory/default/workload-identity/${var.agent_name}-*",
    ]
  }

  statement {
    sid    = "BedrockModelInvocation"
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream",
    ]
    resources = [
      "arn:aws:bedrock:*::foundation-model/*",
      "arn:aws:bedrock:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*",
    ]
  }
}

resource "aws_iam_role_policy" "agent_runtime" {
  name   = "${var.agent_name}-execution"
  role   = aws_iam_role.agent_runtime.id
  policy = data.aws_iam_policy_document.execution.json
}

resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = var.agent_name
  role_arn           = aws_iam_role.agent_runtime.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = var.container_uri
    }
  }

  network_configuration {
    network_mode = var.network_mode
  }

  protocol_configuration {
    server_protocol = "HTTP"
  }

  environment_variables = var.environment_variables

  tags = local.tags

  depends_on = [aws_iam_role_policy.agent_runtime]
}

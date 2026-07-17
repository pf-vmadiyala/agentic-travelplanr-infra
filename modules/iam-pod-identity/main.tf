# Pod Identity roles for in-cluster workloads. Each creates an IAM role
# (trusting pods.eks.amazonaws.com) + an association binding it to a
# namespace/service-account. No OIDC, no SA annotations needed.

# Custom policy: read only this project's secrets. Shared by API, worker, ESO.
data "aws_iam_policy_document" "secrets_read" {
  statement {
    sid    = "ReadProjectSecrets"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    # Scope to the project prefix only — wildcard covers all env secrets
    resources = ["arn:aws:secretsmanager:*:*:secret:${var.secret_name_prefix}/*"]
  }
}

# --- API pod role ---
module "api_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-api"

  attach_custom_policy      = true
  source_policy_documents   = [data.aws_iam_policy_document.secrets_read.json]

  associations = {
    this = {
      cluster_name    = var.cluster_name
      namespace       = var.app_namespace
      service_account = "travel-planner-api"
    }
  }

  tags = local.tags
}

# --- Celery worker pod role ---
module "worker_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-worker"

  attach_custom_policy    = true
  source_policy_documents = [data.aws_iam_policy_document.secrets_read.json]

  associations = {
    this = {
      cluster_name    = var.cluster_name
      namespace       = var.app_namespace
      service_account = "travel-planner-worker"
    }
  }

  tags = local.tags
}

# --- External Secrets Operator role ---
module "eso_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-external-secrets"

  attach_custom_policy    = true
  source_policy_documents = [data.aws_iam_policy_document.secrets_read.json]

  associations = {
    this = {
      cluster_name    = var.cluster_name
      namespace       = "external-secrets"
      service_account = "external-secrets"
    }
  }

  tags = local.tags
}

# --- AWS Load Balancer Controller role ---
module "lb_controller_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name = "${var.cluster_name}-aws-lbc"

  attach_aws_lb_controller_policy = true   # module attaches the AWS-published policy

  associations = {
    this = {
      cluster_name    = var.cluster_name
      namespace       = "kube-system"
      service_account = "aws-load-balancer-controller"
    }
  }

  tags = local.tags
}
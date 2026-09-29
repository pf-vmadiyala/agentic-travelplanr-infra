# Lets GitHub Actions in the app repo push images to ECR without stored AWS keys.
# CI assumes this role via OIDC (see multi-agents-travel-guide/.github/workflows/ci.yml).

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

data "aws_iam_policy_document" "github_ci_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Only runs on the app repo's main branch can assume this role (not PRs or forks).
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:pf-vmadiyala/multi-agents-travel-guide:ref:refs/heads/main"]
    }
  }
}

resource "aws_iam_role" "github_ci" {
  name               = "git-oidc" # must match role-to-assume in ci.yml
  assume_role_policy = data.aws_iam_policy_document.github_ci_trust.json
}

# Push/pull on the app's ECR repository only.
data "aws_iam_policy_document" "github_ci_ecr" {
  statement {
    sid       = "EcrLogin"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid = "EcrPushAppRepo"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [module.ecr.repository_arn]
  }
}

resource "aws_iam_role_policy" "github_ci_ecr" {
  name   = "ecr-push-travel-planner-app"
  role   = aws_iam_role.github_ci.id
  policy = data.aws_iam_policy_document.github_ci_ecr.json
}
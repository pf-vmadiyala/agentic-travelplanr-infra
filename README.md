# Agentic Travel Planner Infrastructure (Terraform)

This repository manages the AWS infrastructure required to deploy and run the multi-agent travel planner application. It utilizes **Terraform** to provision the networking layer, the managed Kubernetes environment, credential placeholders, and secure EKS Pod Identity access roles.

## Repository Structure

```text
agentic-travelplanr-infra/
├── environments/
│   └── dev/                  # Development environment workspace configuration
│       ├── main.tf           # Environment module instantiations
│       ├── providers.tf      # AWS Provider declarations
│       ├── versions.tf       # Terraform version and environment variables
│       ├── dev.tfvars        # Environment variable overrides
│       └── backend-dev.hcl   # S3 remote state backend configuration
├── modules/
│   ├── vpc/                  # VPC Module (Subnets, NAT Gateways, EKS ALB subnet tagging)
│   ├── eks/                  # EKS Module (Control plane, Node groups, AWS addons)
│   ├── secrets/              # Secrets Manager Module (API placeholder variables)
│   ├── iam-pod-identity/     # EKS Pod Identity Module (ESO, LBC, API, and Worker IAM roles)
│   └── bootstrap-argocd/     # GitOps Boostrap Module (ArgoCD, External Secrets, ALB Controller)
└── README.md
```

## Prerequisites

1. **AWS CLI (v2)** installed and authenticated (`aws configure`).
2. **Terraform CLI (v1.12+)** installed.
3. An **S3 Bucket** created in your AWS account to hold the Terraform state files (with Versioning and SSE Encryption enabled).

---

## Deployment Steps

### 1. Initialize the Workspace
Navigate to your environment folder and initialize the S3 remote backend:
```bash
cd environments/dev
terraform init -backend-config=backend-dev.hcl
```

### 2. Validate Code
Ensure that there are no syntax errors or resource conflicts:
```bash
terraform validate
```

### 3. Review the Plan
Perform a dry-run execution plan to verify what AWS resources will be created:
```bash
terraform plan -var-file=dev.tfvars
```

### 4. Apply Changes
Provision the infrastructure on AWS:
```bash
terraform apply -var-file=dev.tfvars
```

---

## Post-Apply Actions (Secrets Manager)

The `secrets` module creates empty placeholders under AWS Secrets Manager with the prefix `agentic-travel-planner/dev/` to establish ARNs. **You must log in to the AWS Console and populate the secret values manually** before deploying the application via GitOps:

* `xai-api-key` (for Grok 4.3 model access)
* `langsmith-api-key` (for tracing dashboards)
* `jwt-secret` (random 32-character string for signing user sessions)
* `openai-api-key` / `anthropic-api-key` (if using fallbacks)
* `google-maps-api-key` (if maps provider is set to `google`)

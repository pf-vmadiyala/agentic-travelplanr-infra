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
│   └── iam-pod-identity/     # EKS Pod Identity Module (ESO, LBC, API, and Worker IAM roles)
└── README.md

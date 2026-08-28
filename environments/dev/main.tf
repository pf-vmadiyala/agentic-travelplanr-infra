# Configures the Virtual Private Cloud (VPC) network infrastructure,
# including public and private subnets across multiple AZs and a NAT gateway.
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.1.0.0/16"
  azs                = ["us-east-2a", "us-east-2b", "us-east-2c"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  single_nat_gateway = true # dev: one NAT to save cost
  cluster_name       = "agentic-travel-planner-dev"
}


# Provisions the Amazon EKS cluster and node groups within the VPC subnets,
# configuring system and application node pools with small instances for development.
module "eks" {
  source = "../../modules/eks"

  cluster_name       = "agentic-travel-planner-dev"
  kubernetes_version = "1.31"

  # Consume VPC module outputs
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Overrides for sandbox environment to use Free Tier eligible instances
  system_instance_types = ["t3.small"]
  app_instance_types    = ["t3.small"]
}

# Sets up AWS Secrets Manager to store application credentials and configuration
# secrets with a prefix, configured for immediate deletion in the development environment.
module "secrets" {
  source                  = "../../modules/secrets"
  name_prefix             = "agentic-travel-planner/dev"
  recovery_window_in_days = 0 # trial account: immediate delete
}


# Configures EKS Pod Identity associations and IAM policies, mapping Kubernetes service accounts
# in the application namespace to IAM roles to access Secrets Manager.
module "iam_pod_identity" {
  source = "../../modules/iam-pod-identity"

  cluster_name       = "agentic-travel-planner-dev"
  secret_name_prefix = module.secrets.secret_name_prefix
  app_namespace      = "travel-planner"

  depends_on = [module.eks] # associations need the cluster + pod-identity agent
}

# Bootstraps Argo CD in the EKS cluster, configuring the root GitOps application
# that points to the travel planner GitOps repository for continuous deployment.
module "bootstrap_argocd" {
  source = "../../modules/bootstrap-argocd"

  cluster_name     = module.eks.cluster_name
  cluster_endpoint = module.eks.cluster_endpoint
  cluster_ca_data  = module.eks.cluster_certificate_authority_data
  region           = var.region
  vpc_id           = module.vpc.vpc_id
  gitops_repo_url  = "https://github.com/pf-vmadiyala/agentic-travelplanr-gitops.git"

  depends_on = [
    module.eks,
    module.iam_pod_identity,
  ]
}



# Provisions an Amazon Elastic Container Registry (ECR) repository to store
# docker container images for the travel planner application.
module "ecr" {
  source    = "../../modules/ecr"
  repo_name = "travel-planner/app"
}

# ECR repository for the customer support agent image built by
# `agentcore launch` (Strands agent running on Bedrock AgentCore Runtime).
module "ecr_customer_support_agent" {
  source    = "../../modules/ecr"
  repo_name = "travel-planner/customer-support-agent"
}

# Deploys the customer support agent to Amazon Bedrock AgentCore Runtime.
# Equivalent to: agentcore create --name CustomerSupport --framework Strands
#                --model-provider Bedrock --memory none
# (No memory resource is created here, matching --memory none.)
module "agentcore_customer_support" {
  source = "../../modules/agentcore"

  agent_name    = "CustomerSupport"
  container_uri = "${module.ecr_customer_support_agent.repository_url}:latest"
}

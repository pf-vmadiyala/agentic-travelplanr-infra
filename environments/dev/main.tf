module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = "10.1.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets    = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
  single_nat_gateway = true # dev: one NAT to save cost
  cluster_name       = "agentic-travel-planner-dev"
}


module "eks" {
  source = "../../modules/eks"

  cluster_name       = "agentic-travel-planner-dev"
  kubernetes_version = "1.31"

  # Consume VPC module outputs
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets

  # Defaults cover dev; override here for prod
  # system_instance_types = ["t3.medium"]
  # app_instance_types    = ["t3.large"]
}

module "secrets" {
  source                  = "../../modules/secrets"
  name_prefix             = "agentic-travel-planner/dev"
  recovery_window_in_days = 0 # trial account: immediate delete
}


module "iam_pod_identity" {
  source = "../../modules/iam-pod-identity"

  cluster_name       = "agentic-travel-planner-dev"
  secret_name_prefix = module.secrets.secret_name_prefix
  app_namespace      = "travel-planner"

  depends_on = [module.eks] # associations need the cluster + pod-identity agent
}

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

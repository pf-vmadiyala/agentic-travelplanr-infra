
# Instantiate the official community VPC module 
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "agentic-travel-planner-${var.environment}-vpc"
  cidr = var.vpc_cidr

  # Distribute subnets across configured AZs or dynamically select the first 3 AZs
  azs             = var.azs != null ? var.azs : slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  #Enable outbound internet routing for private subnets (This is for app to call LLMS)
  enable_nat_gateway     = true
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tag subnets so EKS auto-discovers where to launch public and private load balancers
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1" # Required for public internet-facing ALBs
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1" # Required for internal-only ALBs
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "agentic-travel-planner"
  }

}

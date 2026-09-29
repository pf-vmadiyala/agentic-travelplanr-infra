# EBS CSI driver: IAM role + AWS-managed policy + pod-identity association.
module "ebs_csi_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "~> 2.0"

  name                      = "${var.cluster_name}-ebs-csi"
  attach_aws_ebs_csi_policy = true # attaches AmazonEBSCSIDriverPolicy

  associations = {
    this = {
      cluster_name    = module.eks.cluster_name
      namespace       = "kube-system"
      service_account = "ebs-csi-controller-sa"
    }
  }

  tags = local.tags
}


# EKS cluster: control plane, OIDC provider, node groups, addons.
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # API endpoint access — restrict to your IP CIDR after bootstrap
  endpoint_public_access = true

  # Adds the Terraform caller as a cluster admin (needed to run kubectl)
  enable_cluster_creator_admin_permissions = true

  # Network — consumes the VPC module outputs
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets # nodes live in private subnets

  addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
      # Prefix delegation: each ENI slot hands out a /28 (16 IPs) instead of one IP,
      # lifting the t3.small limit of 11 pods per node. Must be set before nodes join.
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = { before_compute = true } # required for pod-identity roles
    aws-ebs-csi-driver     = {}                        # role supplied by module above
    metrics-server         = {}                        # resource metrics for HPA and `kubectl top`
  }

  # Managed node groups
  eks_managed_node_groups = {
    # System pool: ArgoCD, ESO, LB controller. No taint, so app pods can also land here.
    system = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.system_instance_types
      min_size       = var.system_min_size
      max_size       = var.system_max_size
      desired_size   = var.system_desired_size

      labels                = { role = "system" }
      cloudinit_pre_nodeadm = [local.max_pods_nodeconfig[var.system_max_pods]]
    }

    # App pool: API, workers, Redis, Postgres (dev).
    app = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.app_instance_types
      min_size       = var.app_min_size
      max_size       = var.app_max_size
      desired_size   = var.app_desired_size

      labels                = { role = "app" }
      cloudinit_pre_nodeadm = [local.max_pods_nodeconfig[var.app_max_pods]]
    }

    # Monitoring pool: Prometheus, Loki, Grafana. Pinned to ONE subnet (one AZ) so their
    # EBS volumes can always re-attach when the node is replaced.
    monitoring = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.monitoring_instance_types
      min_size       = 1
      max_size       = 1
      desired_size   = 1
      subnet_ids     = [var.private_subnets[0]]

      labels                = { role = "monitoring" }
      cloudinit_pre_nodeadm = [local.max_pods_nodeconfig[var.monitoring_max_pods]]
    }
  }

  tags = local.tags
}

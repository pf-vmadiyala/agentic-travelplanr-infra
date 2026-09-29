locals {
  tags = {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = "agentic-travel-planner"
  }

  # AL2023 nodeadm config that sets kubelet maxPods explicitly. With prefix delegation the
  # IP limit disappears, so memory becomes the limit: kubelet reserves 11 MiB per pod +
  # 255 MiB, so keep this modest on small nodes (29 on 2 GiB t3.small, 58 on 4-8 GiB).
  max_pods_nodeconfig = {
    for n in distinct([var.system_max_pods, var.app_max_pods, var.monitoring_max_pods]) : n => {
      content_type = "application/node.eks.aws"
      content      = <<-EOT
        ---
        apiVersion: node.eks.aws/v1alpha1
        kind: NodeConfig
        spec:
          kubelet:
            config:
              maxPods: ${n}
      EOT
    }
  }
}

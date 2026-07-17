# AWS Load Balancer Controller
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.lb_controller_chart_version
  namespace  = "kube-system"

  set = [
    {
      name  = "clusterName"
      value = var.cluster_name
    },
    {
      name  = "serviceAccount.create"
      value = "true"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    }
  ]
}

# External Secrets Operator
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.eso_chart_version
  namespace        = "external-secrets"
  create_namespace = true

  set = [
    {
      name  = "serviceAccount.name"
      value = "external-secrets"
    }
  ]
}

# ArgoCD — root App-of-Apps embedded in Helm values (single-apply safe).
# Uses the chart's `server.additionalApplications` to declare the root app
# inline, so there is NO kubernetes_manifest plan-time cluster dependency.
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = "argocd"
  create_namespace = true

  values = [
    yamlencode({
      # Declaratively create the root App-of-Apps via the chart itself.
      applicationSet = { enabled = false }

      server = {
        additionalApplications = [
          {
            name      = "root"
            namespace = "argocd"
            project   = "default"
            source = {
              repoURL        = var.gitops_repo_url
              targetRevision = "main"
              path           = "apps"
            }
            destination = {
              server    = "https://kubernetes.default.svc"
              namespace = "argocd"
            }
            syncPolicy = {
              automated   = { prune = true, selfHeal = true }
              syncOptions = ["CreateNamespace=true"]
            }
          }
        ]
      }
    })
  ]
}
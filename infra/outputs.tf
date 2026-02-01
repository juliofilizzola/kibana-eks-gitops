output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

# output "argocd_lb" {
#   value = helm_release.argocd.resources[?type == "kubernetes.io/Service"].status.loadBalancer.ingress[0].hostname
# }


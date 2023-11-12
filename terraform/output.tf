output "cluster_name" {
  description = "Kubernetes cluster endpoint"
  value       = kind_cluster.vikunja.endpoint
}

output "argocd_chart_version" {
  value       = var.argocd_chart_version
  description = "ArgoCD Helm Chart version"
}
variable "argocd_release_name" {
  type        = string
  description = "Helm release name"
  default     = "argocd"
}
variable "argocd_namespace" {
  description = "Namespace to install ArgoCD chart into"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of ArgoCD chart to install"
  type        = string
  default     = "5.50.1"
}

variable "argocd_admin_password" {
  description = "Default Admin Password"
  type        = string
}
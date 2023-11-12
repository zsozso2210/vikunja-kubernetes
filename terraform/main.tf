
locals {
  cluster_name = "vikunja-local"
}

# Create a test cluster named "vikunja-local" with a control-plane and
# three workers using the inline config argument
resource "kind_cluster" "vikunja" {
  name           = local.cluster_name
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      extra_port_mappings {
        container_port = 80
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 443
        host_port      = 443
      }
      labels = {
        "ingress-ready" = "true"
      }
    }

    node {
      role  = "worker"
      image = "kindest/node:v1.28.0"
      labels = {
        "worker-node" = "true"
      }
    }

    node {
      role  = "worker"
      image = "kindest/node:v1.28.0"
      labels = {
        "worker-node" = "true"
      }
    }
    node {
      role  = "worker"
      image = "kindest/node:v1.28.0"
      labels = {
        "worker-node" = "true"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.vikunja.endpoint
  cluster_ca_certificate = kind_cluster.vikunja.cluster_ca_certificate
  client_certificate     = kind_cluster.vikunja.client_certificate
  client_key             = kind_cluster.vikunja.client_key
}

provider "helm" {
  kubernetes {
    host                   = kind_cluster.vikunja.endpoint
    cluster_ca_certificate = kind_cluster.vikunja.cluster_ca_certificate
    client_certificate     = kind_cluster.vikunja.client_certificate
    client_key             = kind_cluster.vikunja.client_key
  }
}

resource "helm_release" "argocd" {
  depends_on = [kind_cluster.vikunja]

  namespace        = var.argocd_namespace
  create_namespace = true
  name             = var.argocd_release_name
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password == "" ? "" : bcrypt(var.argocd_admin_password)
  }
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  set {
    name  = "configs.params.server\\.basehref"
    value = "/argocd/"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.paths[0]"
    value = "/argocd(/|$)(.*)"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = "localhost"
  }
  set {
    name  = "server.ingress.pathType"
    value = "Prefix"
  }
  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
    value = "/$2"
  }
  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/ssl-redirect"
    value = "false"
  }
  set {
    name  = "server.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/backend-protocol"
    value = "HTTP"
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    name = "vikunja-demo"
    labels = {
      "created-by" = "Terraform"
    }
  }

}

resource "kubernetes_secret_v1" "gcp_sercret_manager" {
  metadata {
    name = "gcpsm-secret"
    labels = {
      "type" = "gcpsm"
    }
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  data = {
    "secret-access-credentials" = "${file("${path.module}/gcpsm-secret.json")}"
  }
}

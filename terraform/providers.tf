terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "0.2.1"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23.0"
    }
  }
}

provider "kind" {
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
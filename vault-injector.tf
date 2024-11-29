provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "google_container_cluster" "my_cluster" {
  name   = var.cluster_name
  region = var.region
}

provider "kubernetes" {
  host = data.google_container_cluster.my_cluster.endpoint

  client_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].client_certificate)
  client_key         = base64decode(data.google_container_cluster.my_cluster.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host                   = data.google_container_cluster.my_cluster.endpoint
    client_certificate     = base64decode(data.google_container_cluster.my_cluster.master_auth[0].client_certificate)
    client_key             = base64decode(data.google_container_cluster.my_cluster.master_auth[0].client_key)
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault_injector" {
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = "1.19.0"

  values = [file("${path.module}/values.yaml")]
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
  path = "kubernetes"
  description = "Kubernetes auth for Vault"
}

resource "vault_kubernetes_auth_backend_config" "example" {
  provider                 = vault_auth_backend.kubernetes.path
  kubernetes_host          = data.google_container_cluster.my_cluster.endpoint
  kubernetes_ca_cert       = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
  token_reviewer_jwt       = var.token_reviewer_jwt
}

resource "vault_kubernetes_auth_backend_role" "example" {
  role_name   = "example-role"
  backend     = vault_auth_backend.kubernetes.path
  bound_service_account_names      = ["example-service-account"]
  bound_service_account_namespaces = ["default"]

  token_policies = ["default"]
  ttl            = "1h"
}

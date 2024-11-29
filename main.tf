terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0.0"
    }
  }

  required_version = ">= 1.0.0"
}


/* provider "vault" {
  address = "https://your-vault-address"
  
  auth_backend = "kubernetes"
  token_reviewer_jwt = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
  kubernetes_ca_cert = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
} */

provider "vault" {
  address = "https://3.92.45.101:8202"

  # Token authentication method
  token           = "" # Vault token, can be stored in a variable or environment variable
  skip_tls_verify = true
}



# Read the JSON file containing the users data
data "local_file" "users_data" {
  filename = "users.json"
}

# Parse the JSON content using jsondecode
locals {
  users = jsondecode(data.local_file.users_data.content)["users"]
}

# Generate UUIDs dynamically for each user
resource "random_uuid" "user_uuids" {
  count = length(local.users)
}

# Create Vault secrets for each user, appending UUID to the user data
resource "vault_generic_secret" "user_secrets" {
  count = length(local.users)

  path = "users-data/${random_uuid.user_uuids[count.index].result}"

  data_json = jsonencode(
    merge(
      {
        uuid       = random_uuid.user_uuids[count.index].result
        email      = local.users[count.index]["email"]
        role       = local.users[count.index]["role"]
        ApiService = local.users[count.index]["ApiService"]
      }
    )
  )
}

/* provider "vault" {
  address = "https://your-vault-address"
  
  auth_backend = "kubernetes"
  token_reviewer_jwt = file("/var/run/secrets/kubernetes.io/serviceaccount/token")
  kubernetes_host = "https://kubernetes.default.svc.cluster.local"
  kubernetes_ca_cert = file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
} */

provider "vault" {
  address = "https://your-vault-address"

  # Token authentication method
  token = ""  # Vault token, can be stored in a variable or environment variable
}
# Read the JSON file containing the users data
data "local_file" "users_data" {
  filename = "secrets_data.json"
}

# Parse the JSON file into a map
data "json" "users_json" {
  json = data.local_file.users_data.content
}

# Generate UUIDs dynamically for each user
resource "random_uuid" "user_uuids" {
  count = length(data.json.users_json.json["users"])
}

# Create Vault secrets for each user, appending UUID to the user data
resource "vault_generic_secret" "user_secrets" {
  count = length(data.json.users_json.json["users"])

  path = "secret/data/users/${random_uuid.user_uuids[count.index].result}"

  data_json = jsonencode(
    merge(
      {
        uuid        = random_uuid.user_uuids[count.index].result
        email       = data.json.users_json.json["users"][count.index]["email"]
        role        = data.json.users_json.json["users"][count.index]["role"]
        ApiService  = data.json.users_json.json["users"][count.index]["ApiService"]
      }
    )
  )
}

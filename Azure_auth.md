```

# Login using Azure AD
vault login -method=azure role="YOUR_AZURE_AD_ROLE"

# Enable AppRole authentication method (if not already enabled)
vault auth enable approle

# Create AppRole with required policies and TTL values
vault write auth/approle/role/my-role policies="default" secret_id_ttl="1h" token_ttl="1h"

# Fetch RoleID for the created AppRole
vault read auth/approle/role/my-role/role-id

# Generate SecretID for the created AppRole
vault write -f auth/approle/role/my-role/secret-id

```

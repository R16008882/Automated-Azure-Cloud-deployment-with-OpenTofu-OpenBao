# 1. Configure the Vault provider to connect to OpenBao
provider "vault" {
  address = "http://127.0.0.1:8200"
  # Note: Using the root token directly is not recommended for production.
  # Consider using a more secure authentication method like AppRole.
  token   = "hvs.S4bIugyJKMX5YYJZRV6lI4I4"
}

# 2. Read the secret from the path you created
data "vault_generic_secret" "azure_credentials" {
  path = "kv/starfleet/dev/azure_spn"
}

# Groupe de Ressources Principal pour l'infrastructure de l'USS Enterprise
resource "azurerm_resource_group" "rg_enterprise" {
  name     = "rg-starfleet-enterprise-prod"
  location = "francecentral"
  tags = {
    Environment = "Production"
    Project     = "StarfleetEnterprise"
  }
}

# provider.tf

  # Les fournisseurs liront automatiquement les variables ARM_* exportées
  # dans votre terminal (ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, etc.)
  # NUL BESOIN de les mentionner explicitement ici.
provider "azurerm" {
  features {}

  client_id       = data.vault_generic_secret.azure_credentials.data["client_id"]
  client_secret   = data.vault_generic_secret.azure_credentials.data["client_secret"]
  tenant_id       = data.vault_generic_secret.azure_credentials.data["tenant_id"]
  subscription_id = data.vault_generic_secret.azure_credentials.data["subscription_id"]
}

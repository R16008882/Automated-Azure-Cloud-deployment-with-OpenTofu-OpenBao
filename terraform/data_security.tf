# Sécurisation des Données Sensibles (Key Vault)
# Création du Key Vault

# Data source to get the Service Principal's object ID
data "azurerm_client_config" "current" {}

# Key Vault pour les données sensibles de l'Enterprise
resource "azurerm_key_vault" "kv_enterprise" {
  name                     = "kv-sf-enterprise-prod"
  location                 = azurerm_resource_group.rg_enterprise.location
  resource_group_name      = azurerm_resource_group.rg_enterprise.name
  enabled_for_disk_encryption = true
  tenant_id                = data.vault_generic_secret.azure_credentials.data.tenant_id # Récupération de l'ID Locataire
  sku_name                 = "standard"

  # Désactiver l'accès réseau public si souhaité pour plus de sécurité (Optionnel)
  public_network_access_enabled = true
}


# Contrôle d'accès aux secrets
# Attribution d'un rôle (Key Vault Contributor) à un groupe Entra ID sur le Plan de Contrôle
resource "azurerm_role_assignment" "kv_access_control" {
  scope                = azurerm_key_vault.kv_enterprise.id
  role_definition_name = "Key Vault Administrator" # Droits complets sur le Key Vault
  principal_id         = azuread_group.officiers_superieurs.object_id
}

# Attribution des Politiques d'accès sur le Plan de Données
resource "azurerm_key_vault_access_policy" "officiers_secrets" {
  key_vault_id = azurerm_key_vault.kv_enterprise.id

  tenant_id    = data.vault_generic_secret.azure_credentials.data.tenant_id
  object_id    = azuread_group.officiers_superieurs.object_id # Utilisation de l'ID du groupe

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover",
    "Backup",
    "Restore",
  ]
  # Les Officiers Supérieurs ont les droits complets sur les secrets.
}

# Donner à notre Service Principal les droits de gérer les secrets
resource "azurerm_key_vault_access_policy" "spn_secrets_access" {
  key_vault_id = azurerm_key_vault.kv_enterprise.id

  tenant_id = data.vault_generic_secret.azure_credentials.data.tenant_id
  object_id = data.azurerm_client_config.current.object_id # ID de notre Service Principal

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
  ]
}


# Stocker un secret sensible
# Secret : Plans du Moteur à Distorsion (Données Confidentielles)
resource "azurerm_key_vault_secret" "secret_plans" {
  depends_on = [azurerm_key_vault_access_policy.spn_secrets_access]
  name         = "warp-core-plans-alpha"
  key_vault_id = azurerm_key_vault.kv_enterprise.id
  value        = "TricobaltExplosionProtocol2258" # Contenu réel du plan
  content_type = "text/plain"
}

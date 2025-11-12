# Log Analytics Workspace pour la Surveillance et l'Audit
# Création de Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "logs_workspace" {
  name                = "log-starfleet-monitoring"
  location            = azurerm_resource_group.rg_enterprise.location
  resource_group_name = azurerm_resource_group.rg_enterprise.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


# Activation du diagnostic sur les Key Vault
# Envoi des logs du Key Vault au Log Analytics Workspace
resource "azurerm_monitor_diagnostic_setting" "kv_logs" {
  name                       = "kv-diagnostic-logs"
  target_resource_id         = azurerm_key_vault.kv_enterprise.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.logs_workspace.id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Confiruation d'une alerte de sécurité
# Groupe d'Action (où envoyer l'alerte, ex: e-mail)
resource "azurerm_monitor_action_group" "incident_response_team" {
  name                = "ag-incident-response"
  resource_group_name = azurerm_resource_group.rg_enterprise.name
  short_name          = "SFResponse"

  # À adapter : Remplacer par une adresse e-mail ou un webhook
  email_receiver {
    name                 = "starfleet_security"
    email_address        = "rachel241@live.fr"
    use_common_alert_schema = true
  }
}

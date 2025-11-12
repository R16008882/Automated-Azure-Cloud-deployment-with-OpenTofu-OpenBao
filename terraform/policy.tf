# Politique 1 : MFA Obligatoire pour le groupe des Officiers Supérieurs
# resource "azuread_conditional_access_policy" "mfa_officiers" {
#   display_name = "CA - Starfleet Officiers Supérieurs MFA"
#   state        = "enabled"
#
#   conditions {
#     client_app_types = ["all"]
#     applications {
#       included_applications = ["All"]
#     }
#     users {
#       included_groups = [azuread_group.officiers_superieurs.object_id]
#     }
#   }
#
#   grant_controls {
#     operator          = "OR"
#     built_in_controls = ["mfa"] # Demander l'authentification multifacteur
#   }
# }

# Simuler des adresses IP autorisées pour l'Enterprise
resource "azuread_named_location" "secteurs_securises" {
  display_name = "Secteurs sécurisés Starfleet"

  ip {
    # Remplacez ceci par l'adresse IP publique de votre VPS/WSL pour les tests
    ip_ranges = ["54.38.242.167/32"]
    trusted   = true
  }
}


# Crér la Politique d'Accès Conditionnel (on cherche à tout bloquer sauf ces lieux)
# resource "azuread_conditional_access_policy" "blocage_non_autorise" {
#   display_name = "CA - Blocage Connexions Non Autorisées"
#   state        = "enabled"
#
#   conditions {
#     client_app_types = ["all"]
#     applications {
#       included_applications = ["All"]
#     }
#     users {
#       included_users = ["All"] # S'applique à tous les utilisateurs
#     }
#     locations {
#       # Pour exclure un lieu, il faut d'abord inclure tous les lieux
#       included_locations = ["All"]
#       # Exclure les emplacements nommés sécurisés
#       excluded_locations = [azuread_named_location.secteurs_securises.id]
#     }
#   }
#
#   grant_controls {
#     operator          = "OR"
#     built_in_controls = ["block"] # Bloquer l'accès pour toutes les autres tentatives
#   }
# }

# Définition des Utilisateurs Clés

# 1. Capitaine (Chef d'Équipe / Officier Supérieur)
resource "azuread_user" "capitaine" {
  display_name = "Capitaine Kirk"
  user_principal_name = "kirk@rachel241live.onmicrosoft.com"
  password      = "UneMDPTresSecurise*1" # A remplacer par un secret OpenBao/Vault ou par la gestion des jetons
  account_enabled = true
}

# 2. Officier Scientifique (Membre d'Équipe)
resource "azuread_user" "officier" {
  display_name = "Officier Spock"
  user_principal_name = "spock@rachel241live.onmicrosoft.com"
  password      = "UnMDPTresSecurise*2"
  account_enabled = true
}

# 3. Ingénieur (Membre d'Équipe)
resource "azuread_user" "ingenieur" {
  display_name = "Ingenieur Scott"
  user_principal_name = "scott@rachel241live.onmicrosoft.com"
  password      = "UnMDPTresSecurise*3"
  account_enabled = true
}


# Définition des Groupes

# Groupe pour les Officiers Supérieurs (MFA obligatoire)
resource "azuread_group" "officiers_superieurs" {
  display_name     = "Starfleet - Officiers Superieurs"
  security_enabled = true
}

# Groupe pour les Équipes Techniques
resource "azuread_group" "equipes_techniques" {
  display_name     = "Starfleet - Equipes Techniques"
  security_enabled = true
}

# Ajouter le Capitaine aux Officiers Supérieurs
resource "azuread_group_member" "kirk_officier" {
  group_object_id  = azuread_group.officiers_superieurs.object_id
  member_object_id = azuread_user.capitaine.object_id
}

# Ajouter l'Officier et l'Ingénieur aux Équipes Techniques
resource "azuread_group_member" "spock_technique" {
  group_object_id  = azuread_group.equipes_techniques.object_id
  member_object_id = azuread_user.officier.object_id
}
resource "azuread_group_member" "scott_technique" {
  group_object_id  = azuread_group.equipes_techniques.object_id
  member_object_id = azuread_user.ingenieur.object_id
}

# Définition du Réseau Virtuel (VNet)
# Nous allons créer un réseau virtuel sécurisé qui servira de "système nerveux" à votre Enterprise.


# 1. Réseau Virtuel (VNet) pour l'USS Enterprise
resource "azurerm_virtual_network" "vnet_enterprise" {
  name                = "vnet-starfleet-enterprise-prod"
  resource_group_name = azurerm_resource_group.rg_enterprise.name
  location            = azurerm_resource_group.rg_enterprise.location
  address_space       = ["10.0.0.0/16"]
}

# 2. Sous-réseaux (Subnets)

# Sous-réseau 1 : Subnet pour les Serveurs Applicatifs (App Tier)
resource "azurerm_subnet" "subnet_app" {
  name                 = "snet-application-tier"
  resource_group_name  = azurerm_resource_group.rg_enterprise.name
  virtual_network_name = azurerm_virtual_network.vnet_enterprise.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Sous-réseau 2 : Subnet pour le Bastion/Jumpbox (Accès Sécurisé)
resource "azurerm_subnet" "subnet_bastion" {
  name                 = "snet-bastion-host"
  resource_group_name  = azurerm_resource_group.rg_enterprise.name
  virtual_network_name = azurerm_virtual_network.vnet_enterprise.name
  address_prefixes     = ["10.0.2.0/24"]
}


# Sécurité Réseau (Groupes de Sécurité Réseau - NSG)
# Pour garantir que les connexions RDP/SSH ne sont autorisées qu'à partir du Bastion (ou d'une plage d'IP spécifique), nous utilisons un NSG.

# 3. Groupe de Sécurité Réseau (NSG) pour les serveurs
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-application-tier"
  location            = azurerm_resource_group.rg_enterprise.location
  resource_group_name = azurerm_resource_group.rg_enterprise.name

  # Règle 1 : Autoriser le trafic INTERNE (ex: du Bastion) pour la gestion
  security_rule {
    name                       = "Allow-MGMT-From-Bastion"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = azurerm_subnet.subnet_bastion.address_prefixes[0] # Source : le subnet du Bastion
    source_port_range          = "*"
    destination_address_prefix = azurerm_subnet.subnet_app.address_prefixes[0]      # Destination : le subnet App
    destination_port_ranges    = ["22", "3389"]                                     # Ports : SSH (22) et RDP (3389)
  }

  # Règle 2 : Bloquer tout autre trafic Internet (par défaut)
  security_rule {
    name                       = "Deny-All-Internet"
    priority                   = 4096 # Priorité la plus basse
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
  }
}

# Association du NSG au Sous-Réseau Applicatif
resource "azurerm_subnet_network_security_group_association" "nsg_app_association" {
  subnet_id                 = azurerm_subnet.subnet_app.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# 4. Déploiement d'une VM Linux de Base

# IP Publique (pour le Bastion ou pour le test initial)
resource "azurerm_public_ip" "pip_vm_test" {
  name                = "pip-vm-test"
  location            = azurerm_resource_group.rg_enterprise.location
  resource_group_name = azurerm_resource_group.rg_enterprise.name
  allocation_method   = "Static"
}

# Interface Réseau
resource "azurerm_network_interface" "nic_vm_test" {
  name                = "nic-vm-test"
  location            = azurerm_resource_group.rg_enterprise.location
  resource_group_name = azurerm_resource_group.rg_enterprise.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet_app.id # Placer la VM dans le subnet sécurisé
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_vm_test.id
  }
}

# La VM elle-même
resource "azurerm_linux_virtual_machine" "vm_test" {
  name                  = "vm-starfleet-server-01"
  location              = azurerm_resource_group.rg_enterprise.location
  resource_group_name   = azurerm_resource_group.rg_enterprise.name
  size                  = "Standard_B1s" # Petite taille pour les tests
  admin_username        = "starfleetadmin"
  network_interface_ids = [azurerm_network_interface.nic_vm_test.id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Authentification par clé SSH (La méthode la plus sécurisée)
  admin_ssh_key {
    username   = "starfleetadmin"
    public_key = file(pathexpand("~/.ssh/id_rsa.pub")) # Assurez-vous d'avoir une clé SSH publique sur votre VPS/WSL
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-starfleet-tofu-state"
    storage_account_name = "ststarfleettofustate"
    container_name       = "tfstate-prod"
    key                  = "terraform.tfstate"
  }
}

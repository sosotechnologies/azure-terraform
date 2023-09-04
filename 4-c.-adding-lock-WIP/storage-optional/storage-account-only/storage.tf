provider "azurerm" {
  features {}
}

# resource "azurerm_resource_group" "cafanwii" {
#   name     = "cafanwii-resource-group"
#   location = "East US"
# }

resource "azurerm_storage_account" "cafanwi_storage" {
  name                     = "cafanwistorage"  # Choose a globally unique name
  resource_group_name      = azurerm_resource_group.cafanwii.name
  location                 = azurerm_resource_group.cafanwii.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "cafanwi_container" {
  name                  = "tfstate-container"  # Choose a unique name
  storage_account_name = azurerm_storage_account.cafanwi_storage.name
  container_access_type = "private"
}

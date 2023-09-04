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

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "app_mainstorage_access" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = azurerm_storage_account.cafanwi_storage.id
}

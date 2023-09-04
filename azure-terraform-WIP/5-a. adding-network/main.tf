provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  # client_id       = var.service_principal_app_id
  # client_secret   = var.service_principal_secret
  
}

provider "azuread" {}

resource "azurerm_resource_group" "cafanwii" {
  name     = "cafanwii-resource-group"
  location = "East US"
}

resource "azurerm_user_assigned_identity" "cafanwii" {
  resource_group_name = azurerm_resource_group.cafanwii.name
  location            = azurerm_resource_group.cafanwii.location

  name = "cafanwii-app-user"
}

resource "azuread_application" "cafanwii" {
  display_name = "cafanwii-terraform-application"
}

resource "azuread_service_principal" "cafanwii" {
  application_id               = azuread_application.cafanwii.application_id
  app_role_assignment_required = false
}

# resource "azuread_application_password" "cafanwii" {
#   application_object_id = azuread_application.cafanwi.object_id

# # # Mark the service principal password resource as ignored for changes
# # lifecycle {
# #   ignore_changes = [azuread_application_password.cafanwi.value]
# # }
# }
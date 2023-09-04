provider "azurerm" {
  features {}
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

# OUtput
output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}
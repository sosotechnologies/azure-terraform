resource "azuread_application_password" "cafanwii" {
  application_object_id = azuread_application.cafanwii.object_id
}

resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}

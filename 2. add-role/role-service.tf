### This is the only resource I added for the role###############
resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}

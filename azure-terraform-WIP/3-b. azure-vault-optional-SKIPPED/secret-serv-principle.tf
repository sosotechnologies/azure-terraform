##################Service  principle secret added################
resource "azuread_application_password" "cafanwii" {
  application_object_id = azuread_application.cafanwii.object_id
}
#################################################################

### This is the only resource I added for the role###############
resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}
###################################################################


# ############### ADDED BELOW FOR CERT ###############
# resource "azurerm_user_assigned_identity" "cafanwii" {
#   # ...

#   identity {
#     type = "UserAssigned"
#     identity_ids = [
#       azurerm_key_vault.cafanwii_key_vault.identity_ids[0],
#     ]
#   }
# }

# resource "azuread_service_principal" "cafanwii" {
#   # ...

#   key_vault_id = azurerm_key_vault.cafanwii_key_vault.id
#   secret {
#     name         = "cafanwii-certificate"
#     value        = azurerm_key_vault_secret.cafanwii_certificate.id
#     certificate = true
#   }
# }

# # Update the azurerm_role_assignment resource to include the new secret
# resource "azurerm_role_assignment" "cafanwii" {
#   principal_id         = azuread_service_principal.cafanwii.object_id
#   role_definition_name = "Contributor"
#   scope                = "/subscriptions/${var.subscription_id}"
# }

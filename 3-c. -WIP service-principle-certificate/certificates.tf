# # certificates.tf
# resource "azurerm_key_vault_certificate" "cafanwii_certificate" {
#   name         = "cafanwii-certificate"
#   key_vault_id = data.azurerm_key_vault.existing_key_vault.id
#   certificate  = filebase64("${path.module}/keys/cafanwii_certificate.pem")
# }

# resource "azurerm_key_vault_certificate" "cafanwii_private_key" {
#   name         = "cafanwii-private-key"
#   key_vault_id = data.azurerm_key_vault.existing_key_vault.id
#   certificate  = filebase64("${path.module}/keys/cafanwii_private_key.pem")
# }

# # Use the certificate in your Azure AD application
# resource "azuread_application" "cafanwii" {
#   display_name = "cafanwii-terraform-application"
#   identifier_uris = ["https://cafanwii-terraform-application"]
  
#   required_resource_access {
#     resource_app_id = azuread_service_principal.cafanwii.application_id
#     resource_access {
#       id   = azuread_service_principal.cafanwii.app_role_id
#       type = "Role"
#     }
#   }
  
#   authentication_certificate {
#     type = "AsymmetricX509Cert"
#     usage = "Verify"
#     key_id = azurerm_key_vault_certificate.cafanwii_certificate.id
#   }
# }

# # Associate the certificate with your existing Azure AD application
# resource "azurerm_service_principal_certificate" "cafanwii" {
#   service_principal_id = azuread_service_principal.cafanwii.id
#   certificate = filebase64("${path.module}/keys/cafanwii_certificate.pem")
#   end_date = "2030-01-01T01:02:03Z"
# }

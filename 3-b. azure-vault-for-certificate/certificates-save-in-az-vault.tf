# # certificates.tf
# data "azurerm_key_vault" "existing_key_vault" {
#   name                = "cafanwii-kv"
#   resource_group_name = azurerm_resource_group.cafanwii.name
# }

# resource "azurerm_key_vault_certificate" "cafanwii_certificate" {
#   name         = "cafanwii-cert"
#   key_vault_id = data.azurerm_key_vault.existing_key_vault.id

#   certificate {
#     contents = file("${path.module}/keys/cafanwii_certificate.pem")
#   }
# }

# resource "azurerm_key_vault_secret" "cafanwii_private_key" {
#   name         = "cafanwii-private-key"
#   key_vault_id = data.azurerm_key_vault.existing_key_vault.id
#   value        = file("${path.module}/keys/cafanwii_private_key.pem")
# }

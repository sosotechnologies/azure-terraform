resource "azurerm_key_vault" "cafanwii_key_vault" {
  name                        = "cafanwii-key-vault"
  location                    = "East US"
  resource_group_name         = azurerm_resource_group.cafanwii.name
  tenant_id                   = var.tenant_id  # You need to define this variable in your variables.tf
  sku_name                    = "standard"     # You can use "standard" or "premium" based on your needs
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
}

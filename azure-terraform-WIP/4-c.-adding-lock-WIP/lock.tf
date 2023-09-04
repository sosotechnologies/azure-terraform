# resource "azurerm_management_lock" "subscription-level" {
#   name       = "prevent-storage-deletion"
#   scope      = "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.cafanwii.name}/providers/Microsoft.Storage/storageAccounts/${azurerm_storage_account.cafanwi_storage.name}/blobServices/default/containers/${azurerm_storage_container.cafanwi_container.name}"
#   lock_level = "CanNotDelete"
# }
#  (Resource Group Level Lock)

resource "azurerm_management_lock" "prevent-deletion" {
  name       = "PreventResourceGroupDeletion"
  scope      = azurerm_resource_group.cafanwii.id
  lock_level = "CanNotDelete"
}

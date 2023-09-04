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


# Error: creating Scoped Lock (Scope: "02586025-9515-4eac-9a28-cd52e33fbaa4"
# │ Lock Name: "PreventsubscriptionDeletion"): unexpected status 404 with error: MissingSubscription: The request did not have a subscription or a valid tenant level resource provider.
# │ 
# │   with azurerm_management_lock.prevent-deletion-subscription,
# │   on lock.tf line 19, in resource "azurerm_management_lock" "prevent-deletion-subscription":
# │   19: resource "azurerm_management_lock" "prevent-deletion-subscription" {
# │ 
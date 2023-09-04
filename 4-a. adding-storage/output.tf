output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}

########### NOT IDEAL to output the secret, for DEMO ONLY##########
output "service_principal_client_secret" {
  value = azuread_application_password.cafanwii.value
  sensitive = true
}

output "resource_group_name" {
  value = azurerm_resource_group.cafanwii.name
}

# output "storage_account_name" {
#   value = azurerm_storage_account.cafanwi_storage.name
# }

# output "container_name" {
#   value = azurerm_storage_container.cafanwi_container.name  # Replace with the actual container name you're using
# }
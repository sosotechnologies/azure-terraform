output "resource_group_name" {
  value = azurerm_resource_group.cafanwii.name
}

output "storage_account_name" {
  value = azurerm_key_vault.cafanwii_key_vault.name
}

output "container_name" {
  value = "cafanwi-container"  # Replace with the actual container name you're using
}

output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}

output "service_principal_client_secret" {
  value     = azuread_application_password.cafanwii.value
  sensitive = true
}



# output "service_principal_application_id" {
#   value = azuread_application.cafanwii.application_id
# }

# ########### NOT IDEAL to output the secret, for DEMO ONLY##########
# output "service_principal_client_secret" {
#   value = azuread_application_password.cafanwii.value
#   sensitive = true
# }


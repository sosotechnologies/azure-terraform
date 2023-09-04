

output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}

########### NOT IDEAL to output the secret, for DEMO ONLY##########
output "service_principal_client_secret" {
  value = azuread_application_password.cafanwii.value
  sensitive = true
}
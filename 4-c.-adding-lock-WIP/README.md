Modifyed:
- output.tf

added:
- storage.tf [azurerm storage account, azurerm storage container]

***NOTE:*** You must configure storage before latr adding backend and lock. So you muct do 4a before 4b

***Note:*** If you choose to deploy just storage byitself. cd into [storage-optional] and run

```
terraform destroy -target=azurerm_storage_container.cafanwi_container
```

# key.tf
resource "azurerm_key_vault" "cafanwii_key_vault" {
  name                        = "cafanwii-key-vault"
  location                    = "East US"
  resource_group_name         = azurerm_resource_group.cafanwii.name
  tenant_id                   = var.tenant_id  # You need to define this variable in your variables.tf
  sku_name                    = "standard"     # You can use "standard" or "premium" based on your needs
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
}

# main.tf
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

provider "azuread" {}

resource "azurerm_resource_group" "cafanwii" {
  name     = "cafanwii-resource-group"
  location = "East US"
}

resource "azurerm_user_assigned_identity" "cafanwii" {
  resource_group_name = azurerm_resource_group.cafanwii.name
  location            = azurerm_resource_group.cafanwii.location

  name = "cafanwii-app-user"
}

resource "azuread_application" "cafanwii" {
  display_name = "cafanwii-terraform-application"
}

resource "azuread_service_principal" "cafanwii" {
  application_id               = azuread_application.cafanwii.application_id
  app_role_assignment_required = false
}

# output.tf
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

output "storage_account_name" {
  value = azurerm_storage_account.cafanwi_storage.name
}

output "container_name" {
  value = azurerm_storage_container.cafanwi_container.name  # Replace with the actual container name you're using
}

secret-serv-principle.tf
resource "azuread_application_password" "cafanwii" {
  application_object_id = azuread_application.cafanwii.object_id
}

resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}

# storage.tf
resource "azurerm_storage_account" "cafanwi_storage" {
  name                     = "cafanwistorage"  # Choose a globally unique name
  resource_group_name      = azurerm_resource_group.cafanwii.name
  location                 = azurerm_resource_group.cafanwii.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "cafanwi_container" {
  name                  = "tfstate-container"  # Choose a unique name
  storage_account_name = azurerm_storage_account.cafanwi_storage.name
  container_access_type = "private"

  lifecycle {
    prevent_destroy = true
  }
}

# terraform.tfvars
subscription_id         = "02586025-9515-4eac-9a28-cd52e33fbaa4"
tenant_id               = "6c5864a4-4b20-4b29-810e-3fb0ca8ca942"

# Variables.tf
variable "subscription_id" {}
variable "tenant_id" {}
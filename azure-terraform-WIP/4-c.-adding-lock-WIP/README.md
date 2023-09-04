

added:
- lock.tf 

***NOTE:*** You must configure storage before later adding backend and lock. So you muct do 4a before 4b

***Note:*** If you choose to deploy just storage byitself. cd into [storage-optional] and run

```
terraform destroy -target=azurerm_storage_container.cafanwi_container
```

## backend.tf
terraform {
  backend "azurerm" {
    resource_group_name   = "cafanwii-resource-group"   # Use your existing resource group name
    storage_account_name = "cafanwistorage"  # Use the storage account name you created
    container_name       = "tfstate-container"  # Use the container name you created
    key                  = "terraform.tfstate"
  }
}

## lock.tf
resource "azurerm_management_lock" "prevent-deletion" {
  name       = "PreventResourceGroupDeletion"
  scope      = azurerm_resource_group.cafanwii.id
  lock_level = "CanNotDelete"
}

## main.tf
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  # client_id       = var.service_principal_app_id
  # client_secret   = var.service_principal_secret
  
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

## output.tf
output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}

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

## ser-principle.tf
resource "azuread_application_password" "cafanwii" {
  application_object_id = azuread_application.cafanwii.object_id
}

resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}

## storage.tf
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

resource "azurerm_role_assignment" "cafanwii_app_mainstorage_access" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Reader and Data Access"
  scope          = azurerm_storage_account.cafanwi_storage.id
}

## terraform.tfvars
service_principal_secret = "PKN8Q~iDRBA5rZAV8cA8qwJ3GfD4pc60poordcMn"
subscription_id         = "2758777e-d279-4b89-b058-dfbf61c1e250"
tenant_id               = "6c5864a4-4b20-4b29-810e-3fb0ca8ca942"

## Variables.tf
variable "subscription_id" {}
variable "tenant_id" {}
variable "service_principal_secret" {}

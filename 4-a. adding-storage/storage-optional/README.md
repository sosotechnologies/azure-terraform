create a certificate key vault and configure as backend.
I've added the backend configuration block and the Azure Key Vault resource definition to the existing main.tf. 
This setup will create the Azure Key Vault resource and configure it as the backend for storing your Terraform state.

I also added a backend.tf file



## az-key-vault.tf
```tf
resource "azurerm_key_vault" "cafanwii_key_vault" {
  name                        = "cafanwii-key-vault"
  location                    = "East US"
  resource_group_name         = azurerm_resource_group.cafanwii.name
  tenant_id                   = var.tenant_id  # You need to define this variable in your variables.tf
  sku_name                    = "standard"     # You can use "standard" or "premium" based on your needs
  enabled_for_disk_encryption = true
  enabled_for_template_deployment = true
}
```

## main.tf
```tf
provider "azurerm" {
  features {}
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
```
## output.tf

```
output "service_principal_application_id" {
  value = azuread_application.cafanwii.application_id
}

########### NOT IDEAL to output the secret, for DEMO ONLY##########
output "service_principal_client_secret" {
  value = azuread_application_password.cafanwii.value
  sensitive = true
}
```

## secret-serv-principle.tf
```tf
resource "azuread_application_password" "cafanwii" {
  application_object_id = azuread_application.cafanwii.object_id
}

resource "azurerm_role_assignment" "cafanwii" {
  principal_id   = azuread_service_principal.cafanwii.object_id
  role_definition_name = "Contributor"
  scope          = "/subscriptions/${var.subscription_id}"
}
```

## terraform.tfvars
```tf
subscription_id         = "02586025-9515-4eac-9a28-cd52e33fbaa4"
tenant_id               = "6c5864a4-4b20-4b29-810e-3fb0ca8ca942"
```

## variables.tf
```tf
variable "subscription_id" {}
variable "tenant_id" {}
```
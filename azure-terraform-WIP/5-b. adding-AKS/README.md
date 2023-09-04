```
chmod 600 ~/.kube/config

az aks get-credentials --resource-group cafanwii-resource-group --name my-aks-cluster
```

added:
- aks.tf
  - modifies file to include the helm provider


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


## network.tf

### Create a virtual network
resource "azurerm_virtual_network" "cafanwii_network" {
  name                = "cafanwii-vnet"
  address_space       = ["10.0.0.0/16"]  # Define your desired address space
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

### Create a subnet within the virtual network
resource "azurerm_subnet" "cafanwii_subnet" {
  name                 = "cafanwii-subnet"
  virtual_network_name = azurerm_virtual_network.cafanwii_network.name
  resource_group_name  = azurerm_resource_group.cafanwii.name
  address_prefixes     = ["10.0.1.0/24"]  # Define your desired subnet address space
}


### Create a Network Security Group (NSG) for controlling inbound and outbound traffic
resource "azurerm_network_security_group" "cafanwii-nsg" {
  name                = "cafanwii-nsg"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

### Define inbound and outbound security rules for the NSG
### Example: Allow HTTP and HTTPS traffic
resource "azurerm_network_security_rule" "http" {
  name                        = "AllowHTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.cafanwii.name
  network_security_group_name = azurerm_network_security_group.cafanwii-nsg.name
}

resource "azurerm_network_security_rule" "https" {
  name                        = "AllowHTTPS"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.cafanwii.name
  network_security_group_name = azurerm_network_security_group.cafanwii-nsg.name
}

### Create a route table
resource "azurerm_route_table" "cafanwii-route-table" {
  name                = "cafanwii-route-table"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

### Define custom routes if needed
### Example: Define a custom route to a specific destination
resource "azurerm_route" "custom-route" {
  name                = "custom-route"
  route_table_name    = azurerm_route_table.cafanwii-route-table.name
  resource_group_name = azurerm_resource_group.cafanwii.name
  address_prefix      = "192.168.1.0/24"  # Define your desired destination address prefix
  next_hop_type       = "VirtualAppliance"  # Update this based on your network setup
  next_hop_in_ip_address = "10.0.1.1"  # Update this with the appropriate next hop IP
}


## aks.tf
# aks.tf
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"  # Path to your kubeconfig file
  }
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "my-aks-cluster"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
  dns_prefix          = "myakscluster"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  service_principal {
    client_id     = azuread_service_principal.cafanwii.application_id
    client_secret = azuread_application_password.cafanwii.value
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
  }

  tags = {
    environment = "development"
  }
}

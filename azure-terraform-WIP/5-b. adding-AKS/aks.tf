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

terraform {
  backend "azurerm" {
    resource_group_name   = "cafanwii-resource-group"   # Use your existing resource group name
    storage_account_name = "cafanwistorage"  # Use the storage account name you created
    container_name       = "tfstate-container"  # Use the container name you created
    key                  = "terraform.tfstate"
  }
}


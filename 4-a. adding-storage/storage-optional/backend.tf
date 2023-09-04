terraform {
  backend "azurerm" {
    resource_group_name   = "cafanwii-resource-group"
    storage_account_name = "cafanwistorage"
    container_name       = "tfstate-container"
    key                  = "terraform.tfstate"
  }
}

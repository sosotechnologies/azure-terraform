resource "azurerm_virtual_network" "cafanwii" {
  name                = "${var.environment_name}-demo4dso-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

resource "azurerm_subnet" "external" {
  name                 = "external"
  virtual_network_name = azurerm_virtual_network.cafanwii.name
  resource_group_name  = azurerm_resource_group.cafanwii.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.environment_name}-dso-pip"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
  allocation_method   = "Static"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_network_security_group" "cafanwii-nsg" {
  name                = "${var.environment_name}-demo4dso-nsg"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name

  security_rule {
    name                       = "http"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "https"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "ssh-app"
    priority                   = 160
    direction                  = "Inbound"
    access                     = var.sshAccess
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "VirtualNetwork"
  }
}

variable "sshAccess" {
  type    = string
  default = "Deny"
}

output "pip" {
  value = azurerm_public_ip.pip.ip_address
}



# network.tf

# Create a virtual network
resource "azurerm_virtual_network" "cafanwii_network" {
  name                = "cafanwii-vnet"
  address_space       = ["10.0.0.0/16"]  # Define your desired address space
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "cafanwii_subnet" {
  name                 = "cafanwii-subnet"
  virtual_network_name = azurerm_virtual_network.cafanwii_network.name
  resource_group_name  = azurerm_resource_group.cafanwii.name
  address_prefixes     = ["10.0.1.0/24"]  # Define your desired subnet address space
}


# Create a Network Security Group (NSG) for controlling inbound and outbound traffic
resource "azurerm_network_security_group" "cafanwii-nsg" {
  name                = "cafanwii-nsg"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

# Define inbound and outbound security rules for the NSG
# Example: Allow HTTP and HTTPS traffic
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

# Create a route table
resource "azurerm_route_table" "cafanwii-route-table" {
  name                = "cafanwii-route-table"
  location            = azurerm_resource_group.cafanwii.location
  resource_group_name = azurerm_resource_group.cafanwii.name
}

# Define custom routes if needed
# Example: Define a custom route to a specific destination
resource "azurerm_route" "custom-route" {
  name                = "custom-route"
  route_table_name    = azurerm_route_table.cafanwii-route-table.name
  resource_group_name = azurerm_resource_group.cafanwii.name
  address_prefix      = "192.168.1.0/24"  # Define your desired destination address prefix
  next_hop_type       = "VirtualAppliance"  # Update this based on your network setup
  next_hop_in_ip_address = "10.0.1.1"  # Update this with the appropriate next hop IP
}

# output "pip" {
#   value = azurerm_public_ip.pip.ip_address
# }
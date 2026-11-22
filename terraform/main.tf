resource "azurerm_resource_group" "honeypot" {
    name     = "rg-honeypot-lab"
    location = "East US" 

tags = {
    Project = "honeypot-lab"
    Owner   = "Nick"
    Environment = "Lab"
    CostCenter = "Portfolio"
    AutoDelete = "Yes"
    }
}

resource "azurerm_virtual_network" "honeypot_vnet" {
    name = "vnet-honeypot"
    address_space = ["10.0.0.0/16"]
    location = azurerm_resource_group.honeypot.location
    resource_group_name = azurerm_resource_group.honeypot.name
    tags = azurerm_resource_group.honeypot.tags
}

resource "azurerm_subnet" "snet" {
  name                            = "snet-honeypot"
  resource_group_name             = azurerm_resource_group.honeypot.name
  virtual_network_name            = azurerm_virtual_network.honeypot_vnet.name
  address_prefixes                = ["10.0.1.0/24"]
  default_outbound_access_enabled = false
}
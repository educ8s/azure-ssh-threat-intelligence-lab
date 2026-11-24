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

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-honeypot"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  tags                = azurerm_resource_group.honeypot.tags

  # --- INBOUND ---
  security_rule {
    name                       = "Allow-Admin-SSH-2222"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "2222"
    source_address_prefixes    = var.admin_source_ips
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-Bait-22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # --- OUTBOUND ---
  security_rule {
    name                       = "Allow-AzureMonitor"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureMonitor"
  }

  security_rule {
    name                       = "Allow-EntraID"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "AzureActiveDirectory"
  }

  security_rule {
    name                       = "Allow-Web-Updates"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "Deny-Attack-Ports"
    priority                   = 130
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "23", "25", "445", "3389"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Outbound"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_link" {
  subnet_id                 = azurerm_subnet.snet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "honeypot_pip" {
  name                = "pip-honeypot"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = azurerm_resource_group.honeypot.tags
}

resource "azurerm_network_interface" "honeypot_nic" {
  name                = "nic-honeypot"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  tags                = azurerm_resource_group.honeypot.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.honeypot_pip.id
  }
}

resource "azurerm_linux_virtual_machine" "honeypot_vm" {
  name                = "vm-honeypot"
  resource_group_name = azurerm_resource_group.honeypot.name
  location            = azurerm_resource_group.honeypot.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.honeypot_nic.id,
  ]
  tags                = azurerm_resource_group.honeypot.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("vm-honeypot_key.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-honeypot"
  location            = azurerm_resource_group.honeypot.location
  resource_group_name = azurerm_resource_group.honeypot.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = azurerm_resource_group.honeypot.tags
  daily_quota_gb = 1
}


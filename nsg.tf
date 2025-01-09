 resource "azurerm_network_security_group" "nsg" {
   name                = "firewall"
   location            = azurerm_resource_group.main.location
   resource_group_name = azurerm_resource_group.main.name
    security_rule {
     name                       = "app"
     priority                   = 100
     direction                  = "Inbound"
     access                     = "Allow"
     protocol                   = "Tcp"
     source_port_range          = "*"
     destination_port_range     = "5000"
     source_address_prefix      = "85.130.213.102/32"
     destination_address_prefix = "*"
   }
    security_rule {
     name                       = "ssh"
     priority                   = 120
     direction                  = "Inbound"
     access                     = "Allow"
     protocol                   = "Tcp"
     source_port_range          = "*"
     destination_port_range     = "22"
     source_address_prefix      = "85.130.213.102/32"
     destination_address_prefix = "*"
   }
 }
 resource "azurerm_network_interface_security_group_association" "nsg" {
   network_interface_id      = azurerm_network_interface.main.id 
   network_security_group_id = azurerm_network_security_group.nsg.id 
 }



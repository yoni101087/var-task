 resource "azurerm_virtual_network" "main" {
   name                = "jonathanfe-terraform-network"
   address_space       = [var.vnet] 
   location            = azurerm_resource_group.main.location
   resource_group_name = azurerm_resource_group.main.name
 }

 resource "azurerm_public_ip" "jonathanfe-public-ip" {
  name                = "puip"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

 resource "azurerm_subnet" "main" {
   name                 = "database"
   resource_group_name  = azurerm_resource_group.main.name
   virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet]
 }

 resource "azurerm_network_interface" "main" {
   name                = "jonathanfe-terraform-nic"
   location            = azurerm_resource_group.main.location
   resource_group_name = azurerm_resource_group.main.name

# fix hard coded
   ip_configuration {
     name                          = "internal"
     subnet_id                     = azurerm_subnet.main.id
     private_ip_address_allocation = "Static" # Use a static IP
     private_ip_address            = "100.16.1.100" # Specify the static private IP
     public_ip_address_id = azurerm_public_ip.jonathanfe-public-ip.id
   }
 }


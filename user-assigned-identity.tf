resource "azurerm_user_assigned_identity" "user" {
  location            = azurerm_resource_group.main.location
  name                = "user"
  resource_group_name = azurerm_resource_group.main.name
}
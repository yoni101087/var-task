data "azurerm_client_config" "current" {}

output "account_id" {
  value = data.azurerm_client_config.current.client_id
}

resource "azurerm_key_vault" "main" {
  name                        = var.key_vault_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"

  # Access policy for your own service principal (Admin)
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover"]
  }

  # Access policy for the User-Assigned Managed Identity
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.user.principal_id  # Correct reference to Managed Identity's principal_id

    secret_permissions = ["Get", "List"]  # Grant permissions to read secrets
  }
}

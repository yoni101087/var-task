#######################################################
# 1. Create a Storage Account
#######################################################
resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}sa"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

#######################################################
# 2. Create a Blob Container
#######################################################
resource "azurerm_storage_container" "blob_container" {
  name                  = "${var.prefix}-logs"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

#######################################################
# 3. Generate a Container-Level SAS Token
#######################################################
data "azurerm_storage_account_sas" "sas" {
  connection_string = azurerm_storage_account.sa.primary_connection_string

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  resource_types {
    service   = false
    container = true
    object    = false
  }

  https_only     = true
  signed_version = "2021-08-06"

  start  = "2025-01-01T00:00:00Z"
  expiry = "2026-01-01T00:00:00Z"

  permissions {
    read    = true
    write   = true
    list    = true
    add     = true
    create  = true
    delete  = false
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}


resource "azurerm_key_vault_secret" "storage_sas_secret" {
  name         = "BLOB-SAS-URL"
  key_vault_id = azurerm_key_vault.main.id

  value = format(
    "https://%s.blob.core.windows.net/%s?%s",
    azurerm_storage_account.sa.name,
    azurerm_storage_container.blob_container.name,
    substr(data.azurerm_storage_account_sas.sas.sas, 1, length(data.azurerm_storage_account_sas.sas.sas))
  )
}


resource "azurerm_key_vault_secret" "storage_container_name_secret" {
  name         = "BLOB-CONTAINER-NAME"
  value        = azurerm_storage_container.blob_container.name
  key_vault_id = azurerm_key_vault.main.id
}


# Assign 'Storage Blob Data Contributor' role to the user-assigned identity
resource "azurerm_role_assignment" "blob_storage_access" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.user.principal_id
}

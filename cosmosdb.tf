resource "azurerm_cosmosdb_account" "cosmos" {
  name                = "${var.prefix}-cosmos"
   resource_group_name = azurerm_resource_group.main.name
   location            = azurerm_resource_group.main.location
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  geo_location {
    location            = azurerm_resource_group.main.location
    failover_priority = 0
  }

  consistency_policy {
    consistency_level = "Session"
  }
}


# 2. Create a SQL Database in that Cosmos Account
resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "${var.prefix}-db"
   resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
}

# 3. Create a Container in that DB
resource "azurerm_cosmosdb_sql_container" "container" {
  name                = "${var.prefix}-container"
   resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  database_name       = azurerm_cosmosdb_sql_database.db.name
  partition_key_paths   = ["/id"]

  throughput = 400  # RU/s for this container (or use autoscale settings)
}

# 4. Store primary key as a secret in Key Vault
resource "azurerm_key_vault_secret" "cosmos_key_secret" {
  name         = "COSMOS-KEY"
  value        = azurerm_cosmosdb_account.cosmos.primary_key
  key_vault_id = azurerm_key_vault.main.id
}

# 5. Optionally store other details (endpoint URL, DB name, container name, etc.)
resource "azurerm_key_vault_secret" "cosmos_url_secret" {
  name         = "COSMOS-URL"
  value        = azurerm_cosmosdb_account.cosmos.endpoint
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "cosmos_dbname_secret" {
  name         = "COSMOS-DATABASE-NAME"
  value        = azurerm_cosmosdb_sql_database.db.name
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "cosmos_container_secret" {
  name         = "COSMOS-CONTAINER-NAME"
  value        = azurerm_cosmosdb_sql_container.container.name
  key_vault_id = azurerm_key_vault.main.id
}

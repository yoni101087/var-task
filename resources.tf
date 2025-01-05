resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name     = azurerm_resource_group.example.name
  location                = azurerm_resource_group.example.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appservice-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku {
    tier     = "Dynamic"
    size     = "I1" # The size for a Consumption plan
  }
}

resource "azurerm_application_insights" "example" {
  name                = var.app_insights_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  application_type    = "web"
}

resource "azurerm_function_app" "example" {
  name                       = var.function_app_name
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  app_service_plan_id        = azurerm_app_service_plan.example.id
  storage_account_name       = azurerm_storage_account.example.name
  storage_account_access_key  = azurerm_storage_account.example.primary_access_key
  version                    = "~3" # or "~4" for .NET 5
  os_type                    = "linux"

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python" # Change according to your function's runtime
    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.example.instrumentation_key
    "AzureWebJobsStorage" = azurerm_storage_account.example.primary_connection_string
  }
}
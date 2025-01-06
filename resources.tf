resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = var.storage_account_name
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "serviceplan" {
  name                = "serviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_application_insights" "appinsight" {
  name                = var.app_insights_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "web"
}

#resource "azurerm_app_service_plan" "example" {
#  name                = "azure-functions-test-service-plan"
#  location            = azurerm_resource_group.example.location
#  resource_group_name = azurerm_resource_group.example.name
#
#  sku {
#    tier = "Standard"
#    size = "S1"
#  }
#}


resource "azurerm_linux_function_app" "functionapp" {
  name                = "jonfunctionapp123"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  storage_account_name       = azurerm_storage_account.storageaccount.name
  storage_account_access_key = azurerm_storage_account.storageaccount.primary_access_key
  service_plan_id            = azurerm_service_plan.serviceplan.id
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python" # Change according to your function's runtime
    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsight.instrumentation_key
    "AzureWebJobsStorage" = azurerm_storage_account.storageaccount.primary_connection_string
  }
  site_config {}
}

#resource "azurerm_function_app" "functionapp" { ### deprecated
#  name                       = var.function_app_name
#  resource_group_name = azurerm_resource_group.rg.name
#  location            = azurerm_resource_group.rg.location
#  app_service_plan_id        = azurerm_service_plan.serviceplan.id
#  storage_account_name       = azurerm_storage_account.storageaccount.name
#  storage_account_access_key  = azurerm_storage_account.storageaccount.primary_access_key
#  version                    = "~3" # or "~4" for .NET 5
#  os_type                    = "linux"
#
#  app_settings = {
#    "FUNCTIONS_WORKER_RUNTIME" = "python" # Change according to your function's runtime
#    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appinsight.instrumentation_key
#    "AzureWebJobsStorage" = azurerm_storage_account.storageaccount.primary_connection_string
#  }
#}
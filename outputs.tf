output "function_app_url" {
  value = azurerm_linux_function_app.functionapp.default_hostname
}
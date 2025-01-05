variable "resource_group_name" {
  description = "The name of the resource group for all resources."
  type        = string
  default     = "example-resources"
}

variable "location" {
  description = "The Azure region to deploy the resources."
  type        = string
  default     = "East US"
}

variable "function_app_name" {
  description = "The name of the Azure Function App."
  type        = string
  default     = "examplefunctionapp"
}

variable "storage_account_name" {
  description = "The name of the Azure Storage Account."
  type        = string
  default     = "examplestoraccoun"
}

variable "app_insights_name" {
  description = "The name of the Azure Application Insights."
  type        = string
  default     = "exampleappinsights"
}
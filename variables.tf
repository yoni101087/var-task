variable "resource_group_name" {
  description = "The name of the resource group for all resources."
  type        = string
  default     = "jonathan2-rg"
}

variable "location" {
  description = "The Azure region to deploy the resources."
  type        = string
  default     = "West Europe"
}

variable "function_app_name" {
  description = "The name of the Azure Function App."
  type        = string
  default     = "functionapp1"
}

variable "storage_account_name" {
  description = "The name of the Azure Storage Account."
  type        = string
  default     = "storageccount1112"
}

variable "app_insights_name" {
  description = "The name of the Azure Application Insights."
  type        = string
  default     = "appinsights1"
}
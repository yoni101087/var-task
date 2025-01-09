variable "resource_group_name" {
  type = string
  default = "main"
}

variable "location" {
  type    = string
  default = "West Europe"
}


variable "vnet" {
  type = string 
  default = "100.16.0.0/16"
}

variable "subnet" {
  type = string
  default = "100.16.1.0/24" 
  
}



variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  default = "keyvault-abc12345"
}


variable "prefix" {
  type    = string
  default = "jf12"
}

variable "ssh_key_data" {}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
     version = "~> 4.14"
    }
  }

  backend "azurerm" {
    resource_group_name   = "jonathanfeTF"
    storage_account_name = "jonathanfe"
    container_name       = "jonatfstate"
    key                  = "terraform.tfstate"
  }
}
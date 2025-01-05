terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
     version = "~> 4.14"
    }
  }

  backend "azurerm" {
    resource_group_name   = "jonathanfeTF"
    storage_account_name = "jonathanfecicd"
    container_name       = "jonathanfecicd"
    key                  = "terraform.tfstate"
  }

}
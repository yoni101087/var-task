provider "azurerm" {
    features {}
    subscription_id = "4107cdbb-533c-44bb-abd4-780bed5efb7c"
 }


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
    container_name       = "jonathanfecicd"
    key                  = "terraform.tfstate"
  }

}
provider "azurerm" {
  subscription_id = "4107cdbb-533c-44bb-abd4-780bed5efb7c"
  tenant_id = "6085d3ae-2d96-4fd9-98f0-0751a37c4a90"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
     }

 }
}


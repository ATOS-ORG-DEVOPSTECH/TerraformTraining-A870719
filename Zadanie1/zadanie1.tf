terraform {
    required_providers {
      azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.94"
      }
    }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "resource_group" {
    name        = "TerraformTraining-A870719"
    location    = "West Europe"
  
}



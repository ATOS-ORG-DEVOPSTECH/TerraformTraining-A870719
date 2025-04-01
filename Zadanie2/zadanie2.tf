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

data "azurerm_resource_group" "resource_group" {
    name        = "TerraformTraining-A870719"
  
}


resource "azurerm_virtual_network" "resource_group" {
  name                = "A870719VNET01"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name                = "A870719Subnet01"
    address_prefix      = "10.0.1.0/24"
  }

  subnet {
    name                = "A870719Subnet02"
    address_prefix    = "10.0.2.0/24"
  }

  subnet {
    name                = "A870719Subnet03"
    address_prefix    = "10.0.3.0/24"
  }
}



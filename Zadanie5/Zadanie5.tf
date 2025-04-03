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

#Resource group
data "azurerm_resource_group" "resource_group" {
    name        = "TerraformTraining-A870719"
  
}

#Virtual network
data "azurerm_virtual_network" "virtual_network" {
    name                = "A870719VNET01"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

#Subnet02
data "azurerm_subnet" "subnet2" {
    name = "A870719Subnet02"
    resource_group_name = data.azurerm_resource_group.resource_group.name
    virtual_network_name = data.azurerm_virtual_network.virtual_network.name
}

#Public IP
resource "azurerm_public_ip" "public_ip" {
    name = var.IP_public
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    allocation_method = "Static"
    sku = "Standard"
}


#Load Balancer
resource "azurerm_lb" "load_balancer" {
  name = var.lb_name
  location = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  sku = "Standard"
  
    frontend_ip_configuration {
      name = "A870719PublicIPAddress"
      public_ip_address_id = azurerm_public_ip.public_ip.id
    }
}

#Backend address
resource "azurerm_lb_backend_address_pool" "backend_pool" {
    loadbalancer_id = azurerm_lb.load_balancer.id
    name = var.backend_pool
}

resource "azurerm_lb_backend_address_pool_address" "backend_address_01" {
  name = "A870719LBPublicIPAddress1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  virtual_network_id = data.azurerm_virtual_network.virtual_network.id
  ip_address = "10.0.2.4"
}

resource "azurerm_lb_backend_address_pool_address" "backend_address_02" {
  name = "A870719LBPublicIPAddres2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend_pool.id
  virtual_network_id = data.azurerm_virtual_network.virtual_network.id
  ip_address = "10.0.2.5"
}

#Load balancer rule
resource "azurerm_lb_rule" "lb_rule" {
    loadbalancer_id = azurerm_lb.load_balancer.id
    name = "LBRule"
    protocol = "Tcp"
    frontend_port = 443
    backend_port = 80
    frontend_ip_configuration_name = "A870719PublicIPAddress"
}

output "load_balancer_ID" {
    value = azurerm_lb.load_balancer.id
}
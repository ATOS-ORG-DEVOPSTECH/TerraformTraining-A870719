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

#Network interface for Fronted
resource "azurerm_network_interface" "network_interface_frontend_1" {
    name = "A870719BSTNIC02"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    ip_configuration {
        name = "A870719BSTIP03"
        subnet_id = data.azurerm_subnet.subnet2.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "network_interface_frontend_2" {
    name = "A870719BSTNIC03"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    ip_configuration {
        name = "A870719BSTIP03"
        subnet_id = data.azurerm_subnet.subnet2.id
        private_ip_address_allocation = "Dynamic"
    }
}

#Subnet03
data "azurerm_subnet" "subnet" {
    name = "A870719Subnet03"
    resource_group_name = data.azurerm_resource_group.resource_group.name
    virtual_network_name = data.azurerm_virtual_network.virtual_network.name
}

#Network interface for DB
resource "azurerm_network_interface" "network_interface_DB" {
    name = "A870719BSTNIC04"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    ip_configuration {
        name = "A870719BSTIP04"
        subnet_id = data.azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
    }
}


#VM Frontend
resource "azurerm_windows_virtual_machine" "Widnows_Frontend" {
    count = 2
    name = var.vm_name
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    admin_password = var.pass
    admin_username = var.username
    network_interface_ids = [azurerm_network_interface.network_interface_frontend_${count.index}]
    size = var.vm_size


    os_disk {
      name = "A870719BSTD01"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
      disk_size_gb = var.C_size
    }
    
    source_image_reference {
      publisher = var.vm_publisher
      offer = var.vm_offer
      sku = var.vm_image
      version = var.vm_version
    }
}

#Disk
resource "azurerm_managed_disk" "disk_D" {
    name = "A870719BSTD02"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    storage_account_type = "Standard_LRS"
    create_option = "Empty"
    disk_size_gb = var.D_size
}

#Disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "disk_D_attach" {
  managed_disk_id    = azurerm_managed_disk.disk_D.id
  virtual_machine_id = azurerm_windows_virtual_machine.Widnows_VM.id
  lun                = "10"
  caching            = "ReadWrite"
}


#DB
resource "azurerm_windows_virtual_machine" "Widnows_DB" {
    name = var.db_name
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    admin_password = var.pass
    admin_username = var.username
    network_interface_ids = [azurerm_network_interface.network_interface_DB.id]
    size = var.vm_size


    os_disk {
      name = "A870719BSTD01"
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
      disk_size_gb = var.C_size
    }
    
    source_image_reference {
      publisher = var.vm_publisher
      offer = var.vm_offer
      sku = var.vm_image
      version = var.vm_version
    }
}

#Disk
resource "azurerm_managed_disk" "disk_D_DB" {
    name = "A870719BSTD08"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name
    storage_account_type = "Standard_LRS"
    create_option = "Empty"
    disk_size_gb = var.D_size
}

#Disk attachment
resource "azurerm_virtual_machine_data_disk_attachment" "disk_D_DB_attach" {
  managed_disk_id    = azurerm_managed_disk.disk_D_DB.id
  virtual_machine_id = azurerm_windows_virtual_machine.Widnows_DB.id
  lun                = "10"
  caching            = "ReadWrite"
}

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

############################################################################################
#Data Block

#Resource group
data "azurerm_resource_group" "resource_group" {
    name        = "TerraformTraining-A870719"
}

#Virtual network
data "azurerm_virtual_network" "virtual_network" {
    name                = "A870719VNET01"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

#Virtual network interface Bastion
data "azurerm_network_interface" "network_interface_bst" {
    name =   "A870719BSTNIC01"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

#Virtual network interface Frontend1
data "azurerm_network_interface" "network_interface_fnd1" {
    name =   "A870719FNDNIC1"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

#Virtual network interface Frontend2
data "azurerm_network_interface" "network_interface_fnd2" {
    name =   "A870719FNDNIC2"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

#Virtual network interface DB
data "azurerm_network_interface" "network_interface_db" {
    name =   "A870719DBANIC01"
    resource_group_name = data.azurerm_resource_group.resource_group.name
}

# #Bastion VM
# data "azurerm_windows_virtual_machine" "bastion_vm" {
#     name = "A870719VMBST1"
#     resource_group_name = data.azurerm_resource_group.resource_group.name
# }

# #Frontend 1
# data "azurerm_windows_virtual_machine" "frontend1_vm" {
#     name = "A870719VMFND1"
#     resource_group_name = data.azurerm_resource_group.resource_group.name
# }

# #Frontend 2
# data "azurerm_windows_virtual_machine" "frontend2_vm" {
#     name = "A870719VMFND2"
#     resource_group_name = data.azurerm_resource_group.resource_group.name
# }

# #DB
# data "azurerm_windows_virtual_machine" "db_vm" {
#     name = "A870719VMDB1"
#     resource_group_name = data.azurerm_resource_group.resource_group.name
# }

##############################################################################
#Resource Block

#Security group Bastion
resource "azurerm_network_security_group" "sg_bastion" {
    name = "bastion_inbound"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    security_rule { 
        name = var.bst_sg_name
        priority = 110
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = 3389
        destination_port_range = 3389
        source_address_prefix = "*"
        destination_address_prefix = "10.0.1.4"
    }
}

#Security group DB
resource "azurerm_network_security_group" "sg_db" {
    name = "database_inbound"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    security_rule { 
        name = var.bst_sg_name
        priority = 110
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = 1433
        destination_port_range = 1433
        source_address_prefixes = ["10.0.2.4","10.0.2.5"]
        destination_address_prefix = "10.0.3.4"
    }
}

#Security group Frontend1
resource "azurerm_network_security_group" "sg_fnt1" {
    for_each = var.frontend_rule
    name = "frontend_inbound_${each.key}"
    location = data.azurerm_resource_group.resource_group.location
    resource_group_name = data.azurerm_resource_group.resource_group.name

    dynamic "security_rule" {
        for_each = each.value.inbound
        content { 
        
        name = security_rule.value.name
        priority = security_rule.value.priority
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = security_rule.value.source_port
        destination_port_range = security_rule.value.destination_port
        source_address_prefix = security_rule.value.source_address
        destination_address_prefix = security_rule.value.destination_address
    }
    }

}

#Security group Frontend2
# resource "azurerm_netowrk_security_group" "sg_fnt2" {
#     name = "frontend_inbound2"
#     location = azurerm_resource_group.resource_group.location
#     resource_group_name = azurerm_resource_group.resource_group.name

#     dynamic security_rule { 
#         for_each =  frontend_rules.frontend2
#         name = frontend_rules.frontend2.value["name"]
#         priority = frontend_rules.frontend2.value["priority"]
#         direction = "Inbound"
#         access = "Allow"
#         protocol = "Tcp"
#         source_port_range = frontend_rules.frontend2.value["source_port"]
#         destination_port_range = frontend_rules.frontend2.value["destination_port"]
#         source_address_prefix = frontend_rules.frontend2.value["source_address"]
#         destianation_address_prefix = frontend_rules.frontend2.value["destination_address"]
#     }
# }

#Associating Security Group to Bastion
resource "azurerm_network_interface_security_group_association" "association_bst" {
  network_interface_id      = data.azurerm_network_interface.network_interface_bst.id
  network_security_group_id = azurerm_network_security_group.sg_bastion.id
}

#Associating Security Group to DB
resource "azurerm_network_interface_security_group_association" "association_db" {
  network_interface_id      = data.azurerm_network_interface.network_interface_db.id
  network_security_group_id = azurerm_network_security_group.sg_db.id
}

#Associating Security Group to Frontend
resource "azurerm_network_interface_security_group_association" "association_fnd1" {
  network_interface_id      = data.azurerm_network_interface.network_interface_fnd1.id
  network_security_group_id = azurerm_network_security_group.sg_fnt1["frontend1"].id
}

#Associating Security Group to Frontend
resource "azurerm_network_interface_security_group_association" "association_fnd2" {
  network_interface_id      = data.azurerm_network_interface.network_interface_fnd2.id
  network_security_group_id = azurerm_network_security_group.sg_fnt1["frontend2"].id
}

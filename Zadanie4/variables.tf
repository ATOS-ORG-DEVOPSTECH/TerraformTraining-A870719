variable "vm_name" {
    default = "A870719VM"
  
}

variable "vm_size" {
    default = "Standard B2s"
}

variable "vm_image" {
    default = "Windows Server 2019 Datacenter"
}

variable "username" {
    default = "A870719"
}

variable "pass" {
    default = "MyPass1!"  
}

variable "C_size" {
    default = 128
}

variable "D_size" {
    default = 10
}

variable "IP" {
    default = "Yes"
}

variable "vm_publisher" {
    default = "MicrosoftWindowsServer"
}

variable "vm_offer" {
    default = "WindowsServer"
  
}

variable "vm_version" {
    default = "latest"
}

variable "db_name" {
    default = A870719VMDB1
}

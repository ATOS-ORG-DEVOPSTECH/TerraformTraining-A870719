variable "bst_sg_name" {
    default = "Allow_RDP_Inbound"
}

variable "db_sg_name" {
    default = "Allow_SOI_Inbound_From_Frontend"
}

variable "frontend_rule" {
        type = map(object({
            inbound = list (object({
                name = string
                priority = number
                source_port = number
                destination_port = string
                source_address = string
                destination_address = string
            }))

    }))
}
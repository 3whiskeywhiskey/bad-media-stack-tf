variable "name" {
    type = string
}

variable "namespace" {
  type = string
}

variable "target" {
    type = object({
        portal = string
        iqn = string
        lun = number
    })
}

variable "storage_class" {
    type = string
    default = "iscsi"
}

variable "storage_size" {
    type = string
    default = "1Gi"
}

variable "fs_type" {
    type = string
    default = "ext4"
}

variable "read_only" {
    type = bool
    default = false
}

variable "chap_auth_discovery" {
    type = bool
    default = false
}

variable "chap_auth_session" {
    type = bool
    default = false
}
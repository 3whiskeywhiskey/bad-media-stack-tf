variable "name" {}
variable "namespace" {}
variable "storage_class" {
    type = string
    default = "nfs-client"
}
variable "storage_size" {
    type = string
    default = "1Gi"
}

variable "nfs_path" {
    type = string
    default = ""
}

variable "nfs_server" {
  type = string
  default = ""
}

variable "access_modes" {
  type = list(string)
  default = ["ReadWriteMany"]
}

resource "kubernetes_persistent_volume_claim" "claim" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    access_modes = var.access_modes

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    storage_class_name = var.storage_class
    volume_name = var.nfs_path != "" ? kubernetes_persistent_volume.volume[0].metadata.0.name : null
  }
}

resource "kubernetes_persistent_volume" "volume" {
  count = var.nfs_path != "" ? 1 : 0

  metadata {
    name = "${var.namespace}-${var.name}"
  }
  spec {
    capacity = {
      storage = var.storage_size
    }
    access_modes = var.access_modes
    storage_class_name = var.storage_class

    persistent_volume_source {
      nfs {
        path   = var.nfs_path
        server = var.nfs_server
      }
    }
  }
}

output "claim_name" {
  value = kubernetes_persistent_volume_claim.claim.metadata.0.name
}

output "storage_size" {
  value = var.storage_size
}
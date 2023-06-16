variable "postgres_storage_size" {
  type        = string
  description = "PostgreSQL storage size"
  default     = "40Gi"
}

variable "postgres_nfs_path" {
  type        = string
  description = "PostgreSQL NFS path"
  default     = "/micron/media/db"
}

variable "nfs_server" {
    type = string
}

variable "storage_class" {
    type = string
    default = "nfs-client"
}

module "db-storage" {
  source = "../nfs-storage"
  name = "postgres"
  namespace = var.namespace
  storage_class = var.storage_class
  access_modes = ["ReadWriteOnce"]
  nfs_server = var.nfs_server
  nfs_path = var.postgres_nfs_path
  storage_size = var.postgres_storage_size
}

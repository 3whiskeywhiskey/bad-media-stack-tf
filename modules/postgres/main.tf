variable "namespace" {
  type        = string
  description = "Kubernetes namespace where PostgreSQL will be deployed"
}

variable "postgres_image" {
  type        = string
  description = "PostgreSQL Docker image"
  default     = "postgres:13"
}

variable "postgres_user" {
  type        = string
  description = "PostgreSQL user"
}

variable "postgres_password" {
  type        = string
  description = "PostgreSQL password"
}

variable "postgres_database" {
  type        = string
  description = "PostgreSQL database"
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
      node_port = 31000
    }

    type = "NodePort"
  }
}

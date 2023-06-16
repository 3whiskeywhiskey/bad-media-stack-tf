variable "namespace" {}
variable "app_name" {}
variable "app_image" {}
variable "ingress_host" {}
variable "service_port" {}

variable "config_storage_size" {
  type = string
  default = "10Gi"
}

variable "iscsi_target" {
  type = object({
    portal = string
    iqn = string
    lun = number
  })
}

variable "node_affinity_arch" {
  type    = string
  default = ""
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        dynamic "affinity" {
          for_each = var.node_affinity_arch != "" ? [1] : []
          content {
            node_affinity {
              required_during_scheduling_ignored_during_execution {
                node_selector_term {
                  match_expressions {
                    key      = "kubernetes.io/arch"
                    operator = "In"
                    values   = [var.node_affinity_arch]
                  }
                }
              }
            }
          }
        }
        container {
          name  = var.app_name
          image = var.app_image

          env {
            name  = "PUID"
            value = 1000
          }

          env {
            name  = "PGID"
            value = 1000
          }

          env {
            name  = "TZ"
            value = "America/New_York"
          }

          port {
            container_port = var.service_port
          }

          volume_mount {
            name       = "config"
            mount_path = "/app/config"
          }
        }

        volume {
          name = "config"

          persistent_volume_claim {
            claim_name = module.config-storage.claim_name # Config PVC
          }
        }
      }
    }
  }
}

module "config-storage" {
  source = "../iscsi-storage"
  namespace = var.namespace
  name = "${var.app_name}-config"
  target = var.iscsi_target
  storage_size = var.config_storage_size
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = var.namespace
  }

  spec {
    port {
      port        = var.service_port
      target_port = var.service_port
      protocol    = "TCP"
    }

    selector = {
      app = var.app_name
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "app" {
  wait_for_load_balancer = true
  metadata {
    name      = var.app_name
    namespace = var.namespace

    annotations = {
      "kubernetes.io/ingress.class"                = "nginx"
      "cert-manager.io/cluster-issuer"             = "cert-manager-webhook-dnsimple-production"
    }
  }

  spec {
    rule {
      host = var.ingress_host

      http {
        path {
          path = "/"
          path_type = "ImplementationSpecific"

          backend {
            service {
              name = kubernetes_service_v1.app.metadata.0.name
              port {
                number = var.service_port
              }
            }
          }
        }
      }
    }

    tls {
      hosts = [var.ingress_host]
      secret_name = "${var.app_name}-tls"
    }
  }
}

resource "kubernetes_config_map" "init_script" {
  metadata {
    name      = "postgres-init-script"
    namespace = var.namespace
  }

  data = {
    "init.sql" = file("${path.module}/init.sql")
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/arch"
                  operator = "In"
                  values   = ["amd64"]
                }
              }
            }
          }
        }

        init_container {
          name  = "init-postgres"
          image = var.postgres_image

          command = ["/bin/bash", "-c"]
          args    = ["cp /init.sql /docker-entrypoint-initdb.d/"]

          volume_mount {
            name       = "init-script"
            mount_path = "/init.sql"
            sub_path   = "init.sql"
          }
        }

        container {
          name  = "postgres"
          image = var.postgres_image

          security_context {
            run_as_user  = 1000
            run_as_group = 1000
          }

          env {
            name  = "TZ"
            value = "America/New_York"
          }

          env {
            name  = "POSTGRES_USER"
            value = var.postgres_user
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_password
          }

        #   env {
        #     name  = "POSTGRES_DB"
        #     value = var.postgres_database
        #   }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          volume_mount {
            name       = "init-script"
            mount_path = "/docker-entrypoint-initdb.d/init.sql"
            sub_path   = "init.sql"
          }
        }

        volume {
          name = "postgres-data"

          persistent_volume_claim {
            claim_name = module.db-storage.claim_name
          }
        }

        volume {
          name = "init-script"

          config_map {
            name = kubernetes_config_map.init_script.metadata.0.name
          }
        }
      }
    }
  }
}



resource "kubernetes_persistent_volume_claim" "claim" {
  metadata {
    name      = var.name
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    storage_class_name = var.storage_class
    volume_name = kubernetes_persistent_volume.iscsi_pv.metadata.0.name
  }
}

resource "kubernetes_persistent_volume" "iscsi_pv" {
  metadata {
    name = "${var.namespace}-${var.name}"
  }

  spec {
    capacity = {
      storage = var.storage_size
    }

    access_modes = ["ReadWriteOnce"]

    storage_class_name = var.storage_class
    persistent_volume_reclaim_policy = "Retain"

    persistent_volume_source {
        iscsi {
            target_portal      = var.target.portal
            iqn                = var.target.iqn
            lun                = var.target.lun
            fs_type            = var.fs_type
            read_only          = var.read_only
            # chap_auth_discovery = var.chap_auth_discovery
            # chap_auth_session  = var.chap_auth_session
        }
    }
  }
}

output "claim_name" {
  value = kubernetes_persistent_volume_claim.claim.metadata.0.name
}
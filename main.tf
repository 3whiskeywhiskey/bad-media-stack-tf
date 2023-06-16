provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "media"
  }
}

module "postgres" {
  source = "./modules/postgres"
  namespace = kubernetes_namespace.app.metadata.0.name
  postgres_nfs_path = "/micron/media/db"
  nfs_server = "10.42.224.5"

  postgres_database = "postgres"
  postgres_user = "postgres"
  postgres_password = "postgres"
}

module "jellyfin" {
  source = "./modules/app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "jellyfin"
  app_image = "docker.io/jellyfin/jellyfin:latest"
  ingress_host = "jellyfin.whiskey.works"
  service_port = 8096
  media_nfs_path = "/micron/media/data/media"
  media_mount = "/media"
  nfs_server = "10.42.224.5"
  config_storage_size = "50Gi"
}

module "nzbhydra2" {
  source = "./modules/iscsi-app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "nzbhydra2"
  app_image = "ghcr.io/linuxserver/nzbhydra2:latest"
  ingress_host = "hydra.whiskey.works"
  service_port = 5076
  node_affinity_arch = "amd64"
  config_target = {
    portal = "10.42.224.5:3260",
    iqn = "iqn.2003-01.org.linux-iscsi.media.x8664:sn.mediastack",
    lun = "2"
  }
}

module "radarr" {
  source = "./modules/app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "radarr"
  app_image = "ghcr.io/linuxserver/radarr:latest"
  ingress_host = "radarr.whiskey.works"
  service_port = 7878
}

module "sonarr" {
  source = "./modules/iscsi-app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "sonarr"
  app_image = "ghcr.io/linuxserver/sonarr:latest"
  ingress_host = "sonarr.whiskey.works"
  service_port = 8989
  node_affinity_arch = "amd64"
  config_target = {
    portal = "10.42.224.5:3260",
    iqn = "iqn.2003-01.org.linux-iscsi.media.x8664:sn.mediastack",
    lun = "0"
  }
}

module "lidarr" {
  source = "./modules/app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "lidarr"
  app_image = "ghcr.io/linuxserver/lidarr:latest"
  ingress_host = "lidarr.whiskey.works"
  service_port = 8686
}

module "readarr" {
  source = "./modules/app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "readarr"
  app_image = "hotio/readarr:latest"
  ingress_host = "readarr.whiskey.works"
  service_port = 8787
}

module "prowlarr" {
  source = "./modules/app"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "prowlarr"
  app_image = "ghcr.io/linuxserver/prowlarr:latest"
  ingress_host = "prowlarr.whiskey.works"
  service_port = 9696
  node_affinity_arch = "arm64"
}

module "jellyseerr" {
  source = "./modules/jellyseerr"
  namespace = kubernetes_namespace.app.metadata.0.name
  app_name = "jellyseerr"
  app_image = "facetiousian/jellyseerr:latest"
  ingress_host = "jellyseerr.whiskey.works"
  service_port = 5055
  node_affinity_arch = "amd64"
  iscsi_target = {
    portal = "10.42.224.5:3260",
    # iqn = "iqn.2003-01.org.linux-iscsi.jellyseer.x8664:sn.jellyseer",
    iqn = "iqn.2003-01.org.linux-iscsi.media.x8664:sn.mediastack",
    lun = "1"
  }
}


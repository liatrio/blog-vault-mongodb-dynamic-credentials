locals {
  mongodb_root_password = "root"
  mongodb_username      = "username"
  mongodb_password      = "password"
  mongodb_database      = "database"
}

resource "kubernetes_namespace" "mongodb" {
  metadata {
    name = "mongodb"
  }
}

resource "helm_release" "mongodb" {
  chart      = "mongodb"
  name       = "mongodb"
  namespace  = kubernetes_namespace.mongodb.metadata[0].name
  repository = "https://charts.bitnami.com/bitnami"
  wait       = true

  values = [
    templatefile("${path.module}/mongodb-values.yaml.tpl", {
      mongodb_username      = local.mongodb_username
      mongodb_password      = local.mongodb_password
      mongodb_database      = local.mongodb_database
      mongodb_root_password = local.mongodb_root_password
    })
  ]
}

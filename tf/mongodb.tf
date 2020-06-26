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
    file("${path.module}/mongodb-values.yaml")
  ]
}

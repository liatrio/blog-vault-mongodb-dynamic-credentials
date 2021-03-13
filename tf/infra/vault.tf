
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "helm_release" "vault" {
  chart      = "vault"
  name       = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name
  repository = "https://helm.releases.hashicorp.com"
  wait       = true
  version    = "0.6.0"

  values = [
    file("${path.module}/vault-values.yaml")
  ]
}


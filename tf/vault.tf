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

  values = [
    file("${path.module}/vault-values.yaml")
  ]
}

resource "kubernetes_service_account" "vault_token_reviewer" {
  metadata {
    name      = "vault-token-reviewer"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding" "vault_token_reviewer" {
  metadata {
    name = "vault-tokenreview-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.vault_token_reviewer.metadata[0].name
    namespace = kubernetes_service_account.vault_token_reviewer.metadata[0].namespace
  }
}

data "kubernetes_secret" "vault_token_reviewer_service_account_token" {
  metadata {
    name      = kubernetes_service_account.vault_token_reviewer.default_secret_name
    namespace = kubernetes_service_account.vault_token_reviewer.metadata[0].namespace
  }
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

resource "vault_kubernetes_auth_backend_config" "k8s_vault_backend_config" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.docker.internal:6443"
  kubernetes_ca_cert = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["ca.crt"]
  token_reviewer_jwt = data.kubernetes_secret.vault_token_reviewer_service_account_token.data["token"]
}

resource "vault_kubernetes_auth_backend_role" "test" {
  backend                          = vault_auth_backend.kubernetes.path
  bound_service_account_names      = [
    "*"
  ]
  bound_service_account_namespaces = [
    "*"
  ]
  role_name                        = "test"
}

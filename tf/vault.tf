locals {
  vault_mongodb_role = "mongodb"
}

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

resource "vault_policy" "get_mongodb_creds" {
  name   = "get-mongodb-creds"
  policy = <<EOF
path "database/creds/mongodb" {
  capabilities = ["read"]
}
EOF
}

resource "vault_policy" "token_lookup_self" {
  name   = "token-lookup-self"
  policy = <<EOF
path "auth/token/lookup-self" {
  capabilities = ["read", "update"]
}
EOF
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

  token_ttl      = 300
  token_max_ttl  = 300
  token_policies = [
    vault_policy.get_mongodb_creds.name,
    vault_policy.token_lookup_self.name,
    "default"
  ]
}

resource "vault_mount" "mongodb" {
  path = "database"
  type = "database"
}

resource "vault_database_secret_backend_connection" "mongodb" {
  backend = vault_mount.mongodb.path
  name    = "mongodb"

  allowed_roles = [
    local.vault_mongodb_role
  ]

  data = {
    username = "root"
    password = local.mongodb_root_password
  }

  mongodb {
    connection_url = "mongodb://{{username}}:{{password}}@mongodb.mongodb.svc.cluster.local:27017/admin"
  }
}

resource "vault_database_secret_backend_role" "mongodb_role" {
  backend             = vault_mount.mongodb.path
  creation_statements = [
    jsonencode({
      db    = "admin"
      roles = [
        {
          role = "readWrite"
          db   = local.mongodb_database
        }
      ]
    })
  ]

  db_name = vault_database_secret_backend_connection.mongodb.name
  name    = local.vault_mongodb_role

  default_ttl = 60
  max_ttl     = 60
}

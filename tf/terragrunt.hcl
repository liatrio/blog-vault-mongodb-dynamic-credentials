remote_state {
  backend = "kubernetes"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    secret_suffix  = "${path_relative_to_include()}-tfstate"
    namespace      = "default"
    config_context = "docker-desktop"
    config_path = "~/.kube/config"
  }
}

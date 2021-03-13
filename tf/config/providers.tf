
provider "kubernetes" {
  config_context = "docker-desktop"
  config_path    = "~/.kube/config"
}

provider "vault" {
  address = "http://localhost:8200"
  token   = "root"
}

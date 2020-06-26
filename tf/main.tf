provider "vault" {
  address = "http://localhost:8200"
  token   = "root"
}

provider "kubernetes" {
  config_context = "docker-desktop"
}

provider "helm" {
  kubernetes {
    config_context = "docker-desktop"
  }
}

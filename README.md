# vault-mongodb

experimenting with vault ephemeral mongodb credentials

## tools used

- kubernetes (local cluster via docker for mac)
- vault
- vault agent
- vault agent injector
- mongodb
- terragrunt / terraform
- helm
- skaffold

## setup

- switch to `docker-desktop` kube context
- run `terragrunt apply` to setup vault and mongodb
- run `skaffold dev --force=false`

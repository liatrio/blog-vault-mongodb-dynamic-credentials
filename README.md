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
- run `terragrunt apply -target helm_release.vault` to setup the vault server
- run `terragrunt apply` to setup the mongodb database and vault configuration
- run `skaffold dev --force=false --port-forward`

## usage

the main app endpoint is `http://localhost:5555/`. this will query the mongodb database using
a set of ephemeral credentials provided by vault, and give you a response with the sample
pet collection and the username and password used for the connection.

the lease for the mongodb credentials expires every minute (for demonstration purposes, this
is obviously way too low for a production environment). when the lease expires, the vault agent
sidecar will renew the lease and update the secret file with the new credentials. the app is watching
this file for updates, and will update the mongodb connection using the new credentials.

you can watch the credentials updating in real time with some bash:

```bash
$ while true; do curl --silent http://localhost:5555 | jq; sleep 1; done
```

# blog-vault-mongodb-dynamic-credentials

A small lab setup for experimenting with vault ephemeral mongodb credentials.

## Technology Stack
- Runtime Environment:
  - kubernetes (local cluster via docker for mac)
- Dynamic Secrets Provider:
  - [vault](https://www.vaultproject.io/)
  - [vault k8s agent injector](https://www.vaultproject.io/docs/platform/k8s/injector)
- Example Secured Resource:
  - mongodb - A database
- Deployment Tools:
  - [terragrunt](https://terragrunt.gruntwork.io/) / [terraform](https://www.terraform.io/) - deploy infra/services
  - [helm](https://helm.sh/) - template kubernetes configurations
  - [skaffold](https://skaffold.dev/) - continuously deploy containerized apps/helm charts.

## Prerequisite tooling you must install to use this example
 - [Docker for Desktop](https://www.docker.com/products/docker-desktop)
   - Install, start and enable Kubernetes.

#### All binaries should be installed and made available in $PATH
 - [helm](https://helm.sh/docs/intro/quickstart/#install-helm)
 - [skaffold](https://skaffold.dev/docs/install/)
 - [terraform](https://www.terraform.io/downloads.html)
 - [terrgrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)

## Setup
- switch to `docker-desktop` kube context
- run `cd tf && terragrunt run-all apply` to setup the vault and mongodb services

## Example App
```
cd example_app
skaffold dev --force=false --port-forward
```
The main app endpoint is `http://localhost:5555/`. This example will query the mongodb database using
a set of ephemeral credentials provided by vault, and give you a response with the sample
pet collection and the username and password used for the connection.

The lease for the mongodb credentials expires every minute (for demonstration purposes, this
is obviously way too low for a production environment). When the lease expires, the vault agent
sidecar will renew the lease and update the secret file with the new credentials. The app is watching
this file for updates, and will update the mongodb connection using the new credentials.

You can watch the credentials updating in real time with some bash:

```bash
$ while true; do curl --silent http://localhost:5555 | jq; sleep 1; done
```

## Helpful Commands

A `test.sh` script has been provided to demonstrate fetching of ephemeral credentials. 

This process requires us to perform the following steps:

#### get a kubernetes service account token:

```bash
$ kubectl get secret $(kubectl get serviceaccount default -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -D
```

#### get a vault token:

```bash
$ vault write -address=http://localhost:8200 auth/kubernetes/login jwt=${serviceAccountToken} role=test -format=json
```

#### get mongodb creds:

```bash
$ VAULT_TOKEN=${vaultToken} vault read -address=http://localhost:8200 database/creds/mongodb
```

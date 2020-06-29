#!/usr/bin/env bash

set -e

serviceAccountSecret=$(kubectl get serviceaccount default -o jsonpath='{.secrets[0].name}')
serviceAccountToken=$(kubectl get secret ${serviceAccountSecret} -o jsonpath='{.data.token}' | base64 -D)
vaultToken=$(vault write -address=http://localhost:8200 auth/kubernetes/login jwt=${serviceAccountToken} role=test -format=json | jq -r ".auth.client_token")

export VAULT_TOKEN=${vaultToken}

echo "Got Vault Token: ${vaultToken}"
echo "Token info:"
vault token lookup -address=http://localhost:8200

printf "\nDatabase Credentials:\n"
vault read -address=http://localhost:8200 database/creds/mongodb

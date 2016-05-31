#!/bin/bash
set -xe

## Build rancher url to use API
RANCHER_URL="http://$SERVER_PORT_8080_TCP_ADDR:8080"

## some host labels as needed
CATTLE_HOST_LABELS="host=$(hostname)&role=development"

## Waiting for server to be up
timeout 60 sh -c "while ! nc -w 1 server 8080; do sleep 0.1; done;"

## do some stuff like getting jq :)
sudo curl -skL https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq
sudo chmod +x /usr/local/bin/jq

## generate rancher registrationtokens
ID=$(curl -X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
-d "{\"name\":\"$(hostname)\"}" \
"${RANCHER_URL}/v1/projects/1a5/registrationtokens" | jq -r .id)

## need to wait a little bit
sleep 2

## Retrieve rancher registrationtokens
REGISTRATION_URL=$(curl -X GET \
-u "${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY}" \
-H 'Accept: application/json' \
"${RANCHER_URL}/v1/registrationtokens/$ID" | jq -r .registrationUrl)

## Launch rancher-agent
exec env CATTLE_HOST_LABELS=$CATTLE_HOST_LABELS CATTLE_AGENT_IP=$SERVER_PORT_8080_TCP_ADDR /run.sh $REGISTRATION_URL
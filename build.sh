#!/bin/bash -x

POSTGRES_HOST=pgsql-backstage
POSTGRES_PASSWORD=abc123

# Change to src directory
pushd src || exit 1  # Exit if the src folder does not exist

yarn install --immutable

yarn tsc

pushd packages/backend
yarn build:backend --config ../../app-config.yaml --config ../../app-config.production.yaml

# return to root folder
popd && popd

docker network create -d bridge backstage 2>/dev/null

# Build Docker image
docker image build . -f packages/backend/Dockerfile --tag backstage

# run Postgres
docker run \
  -d \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  --name "$POSTGRES_HOST" \
  --network=backstage \
  postgres:17-alpine

sleep 10

# Run Backstage
docker run \
  -e POSTGRES_HOST="$POSTGRES_HOST" \
  -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
  -it \
  --network=backstage \
  -p 7007:7007 \
  backstage
#!/bin/bash -x

# Change to src directory
pushd src || exit 1  # Exit if the src folder does not exist

yarn install --immutable

# Output type definitions to dist-types/ in src, which are then consumed by the build
yarn tsc

# Build the backend, which bundles it all up into the packages/backend/dist folder
yarn build:backend --config ../../app-config.yaml --config ../../app-config.production.yaml

# Build Docker image
docker image build . -f packages/backend/Dockerfile --tag backstage

# Run Backstage and Postgres
docker compose up & python3 -m webbrowser http://localhost:7007
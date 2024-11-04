#!/bin/bash -x

validate_environment() {
  # Check if required environment variables are set
  if [[ -z "${GITHUB_CLIENTID}" || -z "${GITHUB_CLIENTSECRET}" || -z "${GITHUB_USER}" ]]; then
    echo "Error: One or more required environment variables are not set."
    echo "Please set the following variables with non-empty values:"
    echo "  - GITHUB_CLIENTID"
    echo "  - GITHUB_CLIENTSECRET"
    echo "  - GITHUB_USER"
    exit 1
  fi
}

# Change to src directory
if [[ ! -d "src" ]]; then
  echo "no 'src' folder located, exiting"
  exit 1
else
  cd src
fi

# pre-check, fail on exit:
validate_environment

# stop all the things if already running
if docker compose ls | grep -q "^backstage "; then
  echo "Backstage project is running. Stopping it now..."
  docker compose -p backstage down
else
  echo "Project 'backstage' not running, skipping 'docker compose down'"
fi

if [[ ! -d "node_modules" ]]; then
  echo "node_modules folder not found. Running yarn install --immutable..."
  yarn install --immutable
else
  echo "node_modules folder already exists. Skipping yarn install."
fi

# Output type definitions to dist-types/ in src, which are then consumed by the build
yarn tsc

# inject GITHUB_USER for app auth setup
sed -i "s|\$GITHUB_USER|${GITHUB_USER}|g" examples/org.yaml

# pushd packages/backend

# Build the backend, which bundles it all up into the packages/backend/dist folder
# the relative file ref is because the workspace lives in packages/backend 
# (so refs the config two folders up)
yarn build:backend --config ../../app-config.production.yaml

# Build Docker image
docker image build . -f packages/backend/Dockerfile --tag backstage

# reset with variable placeholder so no need to manually unstage
git restore examples/org.yaml

# Run Backstage and Postgres
docker compose up -d

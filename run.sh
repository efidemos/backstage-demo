#!/bin/bash -x

# Change to src directory
if [[ ! -d "src" ]]; then
  echo "no 'src' folder located, exiting"
  exit 1
else
  cd src
fi

if [ "$1" == "prod" ]; then
  docker compose up -d -f docker-compose_prod.yml
else
  docker compose up -d
  yarn dev
fi
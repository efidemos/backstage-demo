#!/bin/bash -x

# Change to src directory
if [[ ! -d "src" ]]; then
  echo "no 'src' folder located, exiting"
  exit 1
else
  cd src
fi

if [ "$1" == "prod" ]; then
  docker compose --file docker-compose_prod.yml up --detach
else
  docker compose up --detach
  yarn dev
fi
#!/bin/bash

# Change to src directory
cd src || exit 1  # Exit if the src folder does not exist

docker image build . -f packages/backend/Dockerfile --tag backstage
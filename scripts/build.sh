#!/bin/bash

SERVICE_NAME=$1

echo "building the project with credentials $BUILD_CREDS"
echo "$SERVICE_NAME" "$(git rev-parse HEAD)" > "$SERVICE_NAME-version.txt"

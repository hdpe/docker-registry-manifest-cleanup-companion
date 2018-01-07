#!/bin/bash
set -e

REGISTRY_LABEL="me.hdpe.docker_registry_manifest_cleanup_companion.registry"

REGISTRY_ID=$(docker ps -qf "label=$REGISTRY_LABEL")

if [ -z "$REGISTRY_ID" ]; then
    echo "Container labelled $REGISTRY_LABEL not found"
    exit 1
fi

echo -n "Waiting for registry..."
until $(curl -s --head --output /dev/null --fail $REGISTRY_URL/v2); do
  sleep 1
  echo -n "."
done

echo

echo "Running docker-registry-cleanup:"
docker-registry-cleanup.sh

# unset these env vars to prevent being picked up by registry and generating a
# warning
unset -v REGISTRY_DIR REGISTRY_URL

echo -n "Stopping registry... "
docker stop $REGISTRY_ID

echo "Running registry garbage-collect:"
registry garbage-collect "${COMPANION_RESOURCES_DIR}/gc-config.yml"

echo -n "Restarting registry... "
docker start $REGISTRY_ID

#!/bin/bash
set -e

if [ -z "$REGISTRY_URL" ]; then
  echo "REGISTRY_URL not set"
  exit 1
fi

if [ -z "$COMPANION_RESOURCES_DIR" ]; then
  echo "COMPANION_RESOURCES_DIR not set"
  exit 1
fi

if [ -z "$REGISTRY_DIR" ]; then
  export REGISTRY_DIR="/registry"
fi

if [ -z "$CLEANUP_SCHEDULE" ]; then
  export CLEANUP_SCHEDULE="0 3 * * *";
fi

(
  cd "$COMPANION_RESOURCES_DIR"

  envsubst < templates/gc-config.tmpl > gc-config.yml
  envsubst < templates/root.crontab.tmpl > /var/spool/cron/crontabs/root
)

crond -f -l0

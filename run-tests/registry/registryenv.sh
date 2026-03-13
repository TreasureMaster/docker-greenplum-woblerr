#!/bin/bash

set -u
set -a; . .env; set +a

# Имя/адрес registry внутри docker-сети
# Например, REGISTRY_HOSTNAME=registry.local:5000
# REGISTRY_LOAD_ADDR="${REGISTRY_HOSTNAME}"
REGISTRY_LOAD_ADDR="localhost:${REGISTRY_HOST_PORT}"

# Где лежат архивы
IMAGES_DIR="./images"
ARCHIVE_GLOB="${IMAGES_DIR}/*.tar.gz"

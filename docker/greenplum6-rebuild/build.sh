#!/bin/bash
set -euo pipefail

IMAGE_TAG="treasuremaster/greenplum:6.27.1-redos7-t4"

if docker image inspect "$IMAGE_TAG" >/dev/null 2>&1; then
    echo "Removing existing image tag: $IMAGE_TAG"
    docker rmi "$IMAGE_TAG"
else
    echo "Image $IMAGE_TAG not found locally, proceeding to build."
fi

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .

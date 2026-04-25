#!/bin/bash

IMAGE_TAG="dwh/postgres:17.9-alpine3.22-cs1"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
# docker build --progress=plain -t "$IMAGE_TAG" .
docker build -t "$IMAGE_TAG" .

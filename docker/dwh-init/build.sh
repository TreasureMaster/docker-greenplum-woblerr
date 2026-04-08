#!/bin/bash

IMAGE_TAG="dwh-init:0.4.2"

# docker build --no-cache --progress=plain -t "$IMAGE_TAG" .
docker build --progress=plain -t "$IMAGE_TAG" .
